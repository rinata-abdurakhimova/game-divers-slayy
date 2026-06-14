class_name Boss67LevelController
extends Node

const WaterRuleServiceScript = preload("res://scripts/gameplay/WaterRuleService.gd")

# ── Map constants ─────────────────────────────────────────────────────────────
const MAP_COLUMNS: int   = 53
const BLOCK_SIZE: float  = 48.0
const MAP_WIDTH_PX: float = MAP_COLUMNS * BLOCK_SIZE   # 2544 px
const FLOOR_TOP_Y: float = 570.0
const VIEWPORT_H: float  = 648.0

# Safe zone spans columns 1-18. Single jump-block at column 13.
# Fight starts the moment player crosses column 19 (the SafeTrigger).
const SAFE_ZONE_COLS: int        = 18
const TUTORIAL_BLOCK_COL: int    = 13
const FIGHT_START_COL: int       = 19

# ── Authored block layout (col 1-53, height 1-8 above floor) ─────────────────
# All blocks are from col 19 onward — safe zone has ONLY the col-13 tutorial block.
const AUTHORED_BLOCKS: Array = [
	# battle zone starts at col 19
	[20,3],[20,4],
	[22,1],[23,1],[23,2],
	[26,2],[26,3],
	[28,3],[28,5],[29,3],
	[32,1],
	[37,1],[38,2],[39,3],[40,1],
	[46,3],[46,5],[47,3],[48,1],[48,4],
	[50,3],[52,3],[53,2],
]

# ── Exports ───────────────────────────────────────────────────────────────────
@export_group("Node Paths")
@export var player_path: NodePath
@export var boss_path: NodePath
@export var camera_path: NodePath
@export var safe_wall_path: NodePath
@export var safe_zone_path: NodePath
@export var safe_trigger_path: NodePath
@export var pickup_root_path: NodePath
@export var projectile_root_path: NodePath
@export var powerup_root_path: NodePath
@export var terrain_visual_path: NodePath
@export var terrain_path: NodePath

@export_group("Scenes")
@export var score_pickup_scene: PackedScene
@export var boss_projectile_scene: PackedScene
@export var powerup_scene: PackedScene

@export_group("Tuning")
@export var purple_distance: int = GameRules.FIRST_PURPLE_DISTANCE_BLOCKS
@export var max_active_pickups: int = 7
@export var pickup_interval_min: float = 2.5
@export var pickup_interval_max: float = 5.0
@export var projectile_interval_min: float = 2.0   # slower attack cadence
@export var projectile_interval_max: float = 3.5
@export var purple_interval_min: float = 3.5
@export var purple_interval_max: float = 6.0
@export var shot_gap_seconds: float = 1.0          # delay between 2 shots in a volley
@export var purple_chance: float = 0.35
@export var first_water_distance: int = GameRules.FIRST_WATER_DISTANCE_BLOCKS
@export var water_retrigger_cooldown_seconds: float = GameRules.WATER_RETRIGGER_COOLDOWN_SECONDS
@export var powerup_interval_min: float = 30.0
@export var powerup_interval_max: float = 60.0

# ── Runtime refs ──────────────────────────────────────────────────────────────
var _player: CharacterBody2D
var _boss: Node2D
var _camera: Camera2D
var _safe_wall: Node
var _safe_zone: Node
var _pickup_root: Node2D
var _projectile_root: Node2D
var _powerup_root: Node2D
var _terrain_visual: Node2D
var _terrain: StaticBody2D

# ── State ─────────────────────────────────────────────────────────────────────
var _tutorial_done: bool = false
var _first_water_started: bool = false
var _first_water_finished: bool = false
var _water_cooldown_left: float = 0.0
var _total_blocks: int = 0
var _local_blocks: int = 0
var _last_blocks: int = -1
var _purple_unlocked: bool = false

var _pickup_timer: Timer
var _projectile_timer: Timer
var _powerup_timer: Timer
var _shot_queue: Array[Dictionary] = []
var _shot_queue_timer: Timer


func _ready() -> void:
	_player          = get_node_or_null(player_path) as CharacterBody2D
	_boss            = get_node_or_null(boss_path)   as Node2D
	_camera          = get_node_or_null(camera_path) as Camera2D
	_safe_wall       = get_node_or_null(safe_wall_path)
	_safe_zone       = get_node_or_null(safe_zone_path)
	_pickup_root     = get_node_or_null(pickup_root_path)  as Node2D
	_projectile_root = get_node_or_null(projectile_root_path) as Node2D
	_powerup_root    = get_node_or_null(powerup_root_path) as Node2D
	_terrain_visual  = get_node_or_null(terrain_visual_path) as Node2D
	_terrain         = get_node_or_null(terrain_path) as StaticBody2D

	_build_authored_blocks()

	if _boss != null:
		_boss.hide()

	_connect_signals()
	_create_timers()


# ── Level geometry ────────────────────────────────────────────────────────────

func _build_authored_blocks() -> void:
	for entry in AUTHORED_BLOCKS:
		var col: int    = entry[0]
		var height: int = entry[1]
		var wx: float = (col - 1) * BLOCK_SIZE + BLOCK_SIZE * 0.5
		var wy: float = FLOOR_TOP_Y - (height - 0.5) * BLOCK_SIZE
		var pos := Vector2(wx, wy)

		if _terrain != null:
			var cs := CollisionShape2D.new()
			var r  := RectangleShape2D.new()
			r.size = Vector2(BLOCK_SIZE, BLOCK_SIZE)
			cs.shape    = r
			cs.position = pos
			_terrain.add_child(cs)

		if _terrain_visual != null:
			var poly := Polygon2D.new()
			var h    := BLOCK_SIZE * 0.5
			poly.polygon = PackedVector2Array([
				Vector2(-h,-h), Vector2(h,-h),
				Vector2(h, h),  Vector2(-h, h),
			])
			poly.color    = Color(0.68, 0.48, 0.22, 1.0)
			poly.position = pos
			_terrain_visual.add_child(poly)


# ── Signals ───────────────────────────────────────────────────────────────────

func _connect_signals() -> void:
	var trigger: Area2D = get_node_or_null(safe_trigger_path) as Area2D
	if trigger != null:
		trigger.body_entered.connect(_on_safe_trigger)

	var ge: Node = get_node_or_null(^"/root/GameEvents")
	if ge == null:
		return
	_opt_connect(ge, &"restart_requested",       _on_restart_requested)
	_opt_connect(ge, &"water_finished",          _on_water_finished)
	_opt_connect(ge, &"score_operation_applied", _on_score_operation_applied)


func _opt_connect(source: Node, sig: StringName, cb: Callable) -> void:
	if source.has_signal(sig) and not source.is_connected(sig, cb):
		source.connect(sig, cb)


func _create_timers() -> void:
	_pickup_timer     = _make_timer(_spawn_pickup)
	_projectile_timer = _make_timer(_queue_volley)
	_powerup_timer    = _make_timer(_spawn_powerup)
	_shot_queue_timer = _make_timer(_fire_next_shot)


func _make_timer(cb: Callable) -> Timer:
	var t := Timer.new()
	t.one_shot = true
	t.timeout.connect(cb)
	add_child(t)
	return t


# ── Process ───────────────────────────────────────────────────────────────────

func _process(delta: float) -> void:
	_update_water_cooldown(delta)

	if _player == null:
		return

	# Camera: follow player X, fixed vertical centre.
	if _camera != null:
		_camera.global_position.x = _player.global_position.x
		_camera.global_position.y = VIEWPORT_H * 0.5

	# Boss hovers just above the top edge of the camera.
	if _tutorial_done and _boss != null and _camera != null:
		_boss.global_position = Vector2(
			_camera.global_position.x,
			_camera.global_position.y - VIEWPORT_H * 0.5 - 30.0
		)

	if not _tutorial_done:
		return

	# ── Screen wrap ────────────────────────────────────────────────────────────
	var px: float = _player.global_position.x
	if px < 0.0:
		_player.global_position.x += MAP_WIDTH_PX
		_total_blocks += MAP_COLUMNS
	elif px >= MAP_WIDTH_PX:
		_player.global_position.x -= MAP_WIDTH_PX
		_total_blocks -= MAP_COLUMNS

	# ── Distance ───────────────────────────────────────────────────────────────
	_local_blocks = int(_player.global_position.x / BLOCK_SIZE)
	var cum: int = _total_blocks + _local_blocks
	if cum == _last_blocks:
		return
	_last_blocks = cum

	var gs: Node = get_node_or_null(^"/root/GameState")
	if gs == null:
		return
	if gs.has_method(&"set_distance_blocks"):
		gs.set_distance_blocks(cum)

	if cum >= purple_distance and not _purple_unlocked:
		_purple_unlocked = true
		if gs.has_method(&"set_boss_phase"):
			gs.set_boss_phase(GameRules.BossPhase.LAND_PURPLE)

	if cum >= first_water_distance and not _first_water_started:
		_trigger_water(&"distance_28")


# ── Tutorial trigger ──────────────────────────────────────────────────────────

func _on_safe_trigger(_body: Node) -> void:
	if _tutorial_done:
		return
	_tutorial_done = true

	# Remove safe zone and wall completely.
	if _safe_zone != null:
		_safe_zone.queue_free()
		_safe_zone = null
	if _safe_wall != null:
		_safe_wall.queue_free()
		_safe_wall = null

	# Reveal Boss 67.
	if _boss != null:
		_boss.show()

	var gs: Node = get_node_or_null(^"/root/GameState")
	if gs != null:
		_total_blocks = 0
		_local_blocks = 0
		_last_blocks  = 0
		if gs.has_method(&"set_distance_blocks"):
			gs.set_distance_blocks(0)
		if gs.has_method(&"set_boss_phase"):
			gs.set_boss_phase(GameRules.BossPhase.LAND_WHITE)

	_start_timers()


# ── Double-shot system ────────────────────────────────────────────────────────
# Each volley = 2 projectiles, 1 second apart.
# Shot 1: aimed directly at the player.
# Shot 2: aimed 96 px ahead OR behind (random).
# Which fires first is shuffled.

func _queue_volley() -> void:
	if _boss == null or _projectile_root == null or boss_projectile_scene == null:
		_start_projectile_timer()
		return

	var use_purple: bool = _purple_unlocked and randf() < purple_chance
	var ops: Array[Dictionary] = _boss_operations()
	var px: float = _player.global_position.x if _player != null else 0.0
	var py: float = FLOOR_TOP_Y - BLOCK_SIZE * 0.5

	# Two target offsets — randomise whether the "flanking" shot is in front or behind.
	var flank: float = (1.0 if randf() > 0.5 else -1.0) * 96.0
	var offsets: Array[float] = [0.0, flank]
	offsets.shuffle()

	_shot_queue.clear()
	for offset in offsets:
		var op: Dictionary = _pick_boss_op(ops)
		_shot_queue.append({
			"operation":   op["operation"],
			"value_cents": op["value_cents"],
			"purple":      use_purple,
			"target_x":    px + offset,
			"target_y":    py,
		})

	_fire_next_shot()
	_start_projectile_timer()


func _fire_next_shot() -> void:
	if _shot_queue.is_empty():
		return
	var data: Dictionary = _shot_queue.pop_front()
	_fire_projectile(data)
	if not _shot_queue.is_empty():
		_shot_queue_timer.start(shot_gap_seconds)


func _fire_projectile(data: Dictionary) -> void:
	if boss_projectile_scene == null or _projectile_root == null:
		return
	var proj: Node2D = boss_projectile_scene.instantiate() as Node2D
	if proj == null:
		return

	proj.set(&"operation",   data["operation"])
	proj.set(&"value_cents", data["value_cents"])
	proj.set(&"is_purple",   data["purple"])

	var spawn: Vector2 = _boss.global_position if _boss != null else Vector2.ZERO
	var target := Vector2(data["target_x"], data["target_y"])
	var dir: Vector2 = (target - spawn).normalized()

	if proj.has_method(&"set_direction"):
		proj.call(&"set_direction", dir)
	else:
		proj.set(&"_direction", dir)

	proj.global_position = spawn
	_projectile_root.add_child(proj)


# Picks a safe boss operation; x0.0 only fires 5% of the time.
func _pick_boss_op(ops: Array[Dictionary]) -> Dictionary:
	var safe_ops: Array[Dictionary] = []
	var zero_op: Dictionary = {}
	for op in ops:
		if op.get("operation") == GameRules.SCORE_OPERATION_MULTIPLY \
				and op.get("value_cents") == 0:
			zero_op = op
		else:
			safe_ops.append(op)
	if not zero_op.is_empty() and randf() < 0.05:
		return zero_op
	if not safe_ops.is_empty():
		return safe_ops[randi() % safe_ops.size()]
	return ops[randi() % ops.size()]


# ── Pickup spawn ──────────────────────────────────────────────────────────────

func _spawn_pickup() -> void:
	if _pickup_root == null or score_pickup_scene == null:
		_start_pickup_timer(); return
	if _pickup_root.get_child_count() >= max_active_pickups:
		_start_pickup_timer(); return

	var pickup: Node2D = score_pickup_scene.instantiate() as Node2D
	if pickup == null:
		_start_pickup_timer(); return

	var ops: Array[Dictionary] = _pickup_operations()
	var op: Dictionary = ops[randi() % ops.size()]
	pickup.set(&"operation",   op["operation"])
	pickup.set(&"value_cents", op["value_cents"])
	pickup.global_position = _random_pickup_pos()
	_pickup_root.add_child(pickup)
	_start_pickup_timer()


func _random_pickup_pos() -> Vector2:
	var cam_x: float = _camera.global_position.x if _camera != null else 300.0
	var x: float = cam_x - 260.0 + randf() * 520.0
	# Either on-floor or 2 blocks above floor.
	var y: float = FLOOR_TOP_Y - BLOCK_SIZE * (0.5 if randf() > 0.5 else 2.5)
	return Vector2(x, y)


# ── Power-up spawn ────────────────────────────────────────────────────────────

func _spawn_powerup() -> void:
	if _powerup_root == null or powerup_scene == null:
		_start_powerup_timer(); return
	if _powerup_root.get_child_count() > 0:
		_start_powerup_timer(); return

	var pw: Node2D = powerup_scene.instantiate() as Node2D
	if pw == null:
		_start_powerup_timer(); return

	var kinds: Array[StringName] = [GameRules.POWERUP_SLOW, GameRules.POWERUP_DOUBLE_JUMP]
	pw.set(&"kind", kinds[randi() % kinds.size()])
	pw.set(&"duration_seconds", GameRules.POWERUP_DURATION_SECONDS)

	# Spawn 4 blocks above the floor — reachable with a jump.
	var cam_x: float = _camera.global_position.x if _camera != null else 300.0
	var x: float = cam_x - 180.0 + randf() * 360.0
	var y: float = FLOOR_TOP_Y - 4.5 * BLOCK_SIZE
	pw.global_position = Vector2(x, y)
	_powerup_root.add_child(pw)
	_start_powerup_timer()


# ── Water ─────────────────────────────────────────────────────────────────────

func _trigger_water(_reason: StringName) -> void:
	var gs: Node = get_node_or_null(^"/root/GameState")
	if gs == null or not gs.has_method(&"begin_water_event"):
		return
	if gs.get("water_variant") != GameRules.WaterVariant.NONE:
		return

	_first_water_started = true
	var variants: Array[GameRules.WaterVariant] = WaterRuleServiceScript.water_variants()
	var chosen: GameRules.WaterVariant = variants[randi() % variants.size()]
	var complication: GameRules.WaterComplication = _pick_complication()

	if gs.has_method(&"set_boss_phase"):
		gs.set_boss_phase(GameRules.BossPhase.WATER)
	gs.begin_water_event(chosen, complication)


func _pick_complication() -> GameRules.WaterComplication:
	match randi() % 3:
		1: return GameRules.WaterComplication.REVERSED_CONTROLS
		2: return GameRules.WaterComplication.INVERTED_GRAVITY
		_: return GameRules.WaterComplication.NONE


func _on_water_finished() -> void:
	if _first_water_started:
		_first_water_finished = true
		_water_cooldown_left  = water_retrigger_cooldown_seconds

	var gs: Node = get_node_or_null(^"/root/GameState")
	if gs == null or not gs.has_method(&"set_boss_phase"):
		return
	gs.set_boss_phase(
		GameRules.BossPhase.LAND_PURPLE if _last_blocks >= purple_distance
		else GameRules.BossPhase.LAND_WHITE
	)


func _on_score_operation_applied(
	operation: StringName,
	value_cents: int,
	source: StringName
) -> void:
	if not _tutorial_done or not _first_water_finished:
		return
	if _water_cooldown_left > 0.0:
		return
	if source != &"score_pickup" or operation != GameRules.SCORE_OPERATION_ADD:
		return
	var units: int = value_cents / 100
	if units > 0 and (units % 6 == 0 or units % 7 == 0):
		_trigger_water(&"score_divisible")


# ── Restart ───────────────────────────────────────────────────────────────────

func _on_restart_requested() -> void:
	_cleanup(_pickup_root)
	_cleanup(_projectile_root)
	_cleanup(_powerup_root)
	_shot_queue.clear()
	_tutorial_done        = false
	_first_water_started  = false
	_first_water_finished = false
	_water_cooldown_left  = 0.0
	_last_blocks          = -1
	_total_blocks         = 0
	_local_blocks         = 0
	_purple_unlocked      = false
	if _boss != null:
		_boss.hide()


# ── Timers ────────────────────────────────────────────────────────────────────

func _start_timers() -> void:
	_pickup_timer.start(randf_range(pickup_interval_min, pickup_interval_max))
	_projectile_timer.start(randf_range(projectile_interval_min, projectile_interval_max))
	_powerup_timer.start(randf_range(powerup_interval_min, powerup_interval_max))


func _start_pickup_timer() -> void:
	_pickup_timer.start(randf_range(pickup_interval_min, pickup_interval_max))


func _start_projectile_timer() -> void:
	var imin: float = purple_interval_min if _purple_unlocked else projectile_interval_min
	var imax: float = purple_interval_max if _purple_unlocked else projectile_interval_max
	_projectile_timer.start(randf_range(imin, imax))


func _start_powerup_timer() -> void:
	_powerup_timer.start(randf_range(powerup_interval_min, powerup_interval_max))


# ── Operations ────────────────────────────────────────────────────────────────

func _pickup_operations() -> Array[Dictionary]:
	var gs: Node = get_node_or_null(^"/root/GameState")
	if gs != null:
		var v: GameRules.WaterVariant = gs.get("water_variant")
		if v != GameRules.WaterVariant.NONE:
			return WaterRuleServiceScript.floor_operations_for_water(v)
	return WaterRuleServiceScript.land_pickup_operations()


func _boss_operations() -> Array[Dictionary]:
	var gs: Node = get_node_or_null(^"/root/GameState")
	if gs != null:
		var v: GameRules.WaterVariant = gs.get("water_variant")
		if v != GameRules.WaterVariant.NONE:
			return WaterRuleServiceScript.boss_operations_for_water(v)
	return WaterRuleServiceScript.land_boss_projectile_operations()


# ── Utility ───────────────────────────────────────────────────────────────────

func _update_water_cooldown(delta: float) -> void:
	if _water_cooldown_left > 0.0:
		_water_cooldown_left = maxf(0.0, _water_cooldown_left - delta)


func _cleanup(node: Node) -> void:
	if node == null:
		return
	for child in node.get_children():
		child.queue_free()
