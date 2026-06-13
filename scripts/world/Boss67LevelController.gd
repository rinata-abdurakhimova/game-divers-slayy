class_name Boss67LevelController
extends Node

const WaterRuleServiceScript = preload("res://scripts/gameplay/WaterRuleService.gd")

# Map is 53 unique columns (x 1..53), column 54 == column 1 (seamless wrap).
const MAP_COLUMNS: int = 53
const BLOCK_SIZE: float = 48.0
const MAP_WIDTH_PX: float = MAP_COLUMNS * BLOCK_SIZE  # 2544 px

# Authored block coordinates from the design board.
# Format: [col_x, height_y] where col_x is 1..53 and height_y is 1..8 (1 = one block above floor).
const AUTHORED_BLOCKS: Array = [
	[2, 1],
	[5, 2],
	[9, 2],
	[11, 1], [11, 4],
	[13, 3],
	[14, 2],
	[15, 2],
	[16, 5],
	[17, 1],
	[18, 4],
	[20, 3], [20, 4],
	[22, 1],
	[23, 1], [23, 2],
	[26, 2], [26, 3],
	[28, 3], [28, 5],
	[29, 3],
	[32, 1],
	[37, 1],
	[38, 2],
	[39, 3],
	[40, 1],
	[46, 3], [46, 5],
	[47, 3],
	[48, 1], [48, 4],
	[50, 3],
	[52, 3],
	[53, 2],
]

@export_group("Node Paths")
@export var player_path: NodePath
@export var boss_path: NodePath
@export var camera_path: NodePath
@export var safe_zone_root_path: NodePath   # Node2D/TileMap containing the safe zone visuals+collision
@export var safe_trigger_path: NodePath
@export var terrain_root_path: NodePath     # Node2D that holds authored blocks
@export var pickup_root_path: NodePath
@export var projectile_root_path: NodePath

@export_group("Tuning")
@export var purple_distance: int = GameRules.FIRST_PURPLE_DISTANCE_BLOCKS
@export var max_active_pickups: int = 7
@export var pickup_interval_min: float = 2.0
@export var pickup_interval_max: float = 4.0
@export var projectile_interval_min: float = 0.8
@export var projectile_interval_max: float = 2.0
@export var purple_interval_min: float = 2.5
@export var purple_interval_max: float = 5.0
@export var purple_chance: float = 0.35
@export var first_water_distance: int = GameRules.FIRST_WATER_DISTANCE_BLOCKS
@export var water_retrigger_cooldown_seconds: float = GameRules.WATER_RETRIGGER_COOLDOWN_SECONDS

@export_group("Scenes")
@export var score_pickup_scene: PackedScene
@export var boss_projectile_scene: PackedScene
@export var block_scene: PackedScene   # StaticBody2D that is a single terrain block

# ── Runtime refs ──────────────────────────────────────────────────────────────
var _player: CharacterBody2D
var _boss: Node2D
var _camera: Camera2D
var _safe_zone_root: Node
var _terrain_root: Node2D
var _pickup_root: Node2D
var _projectile_root: Node2D

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


func _ready() -> void:
	_player = get_node_or_null(player_path) as CharacterBody2D
	_boss   = get_node_or_null(boss_path)   as Node2D
	_camera = get_node_or_null(camera_path) as Camera2D
	_safe_zone_root  = get_node_or_null(safe_zone_root_path)
	_terrain_root    = get_node_or_null(terrain_root_path) as Node2D
	_pickup_root     = get_node_or_null(pickup_root_path)  as Node2D
	_projectile_root = get_node_or_null(projectile_root_path) as Node2D

	# Build authored level geometry.
	_build_authored_blocks()

	# Hide boss until tutorial finishes.
	if _boss != null:
		_boss.hide()
		_boss.set_process(false)
		_boss.set_physics_process(false)

	_connect_signals()
	_create_timers()


# ── Build level ───────────────────────────────────────────────────────────────

func _build_authored_blocks() -> void:
	if _terrain_root == null or block_scene == null:
		push_warning("Boss67LevelController: terrain_root or block_scene not set — skipping block build.")
		return

	# Remove any existing children first (clean slate).
	for child in _terrain_root.get_children():
		child.queue_free()

	for entry in AUTHORED_BLOCKS:
		var col: int = entry[0]   # 1..53
		var height: int = entry[1] # 1..8 (number of blocks above floor)

		var block: Node2D = block_scene.instantiate() as Node2D
		if block == null:
			continue

		# Convert grid coords to world position.
		# X: columns are 1-indexed; multiply by BLOCK_SIZE to get pixel position.
		# Y: Godot Y grows downward. Floor is at row 0 (bottom of visible area).
		#    Visible area is 8 rows tall → total px height = 8 * BLOCK_SIZE = 384.
		#    Floor top = 7 * BLOCK_SIZE from top of view = 336 px.
		#    height=1 means directly on the floor → y = floor_top - BLOCK_SIZE/2... 
		#    but we use top-left origin so: pixel_y = (8 - height) * BLOCK_SIZE
		var pixel_x: float = (col - 1) * BLOCK_SIZE + BLOCK_SIZE * 0.5
		var pixel_y: float = (8 - height) * BLOCK_SIZE - BLOCK_SIZE * 0.5

		block.position = Vector2(pixel_x, pixel_y)
		_terrain_root.add_child(block)


# ── Signals ───────────────────────────────────────────────────────────────────

func _connect_signals() -> void:
	var trigger: Area2D = get_node_or_null(safe_trigger_path) as Area2D
	if trigger != null:
		trigger.body_entered.connect(_on_safe_trigger)

	var ge: Node = get_node_or_null(^"/root/GameEvents")
	if ge != null:
		if ge.has_signal(&"restart_requested"):
			ge.restart_requested.connect(_on_restart_requested)
		if ge.has_signal(&"water_finished"):
			ge.water_finished.connect(_on_water_finished)
		if ge.has_signal(&"score_operation_applied"):
			ge.score_operation_applied.connect(_on_score_operation_applied)


func _create_timers() -> void:
	_pickup_timer = Timer.new()
	_pickup_timer.one_shot = true
	_pickup_timer.timeout.connect(_spawn_pickup)
	add_child(_pickup_timer)

	_projectile_timer = Timer.new()
	_projectile_timer.one_shot = true
	_projectile_timer.timeout.connect(_spawn_projectile)
	add_child(_projectile_timer)


# ── Per-frame ─────────────────────────────────────────────────────────────────

func _process(delta: float) -> void:
	_update_water_cooldown(delta)

	if _player == null or not _tutorial_done:
		return

	# ── Screen wrap: both edges ────────────────────────────────────────────────
	var px: float = _player.global_position.x
	if px < 0.0:
		_player.global_position.x += MAP_WIDTH_PX
		_total_blocks += MAP_COLUMNS
	elif px >= MAP_WIDTH_PX:
		_player.global_position.x -= MAP_WIDTH_PX
		_total_blocks -= MAP_COLUMNS

	# ── Distance tracking ──────────────────────────────────────────────────────
	_local_blocks = int(_player.global_position.x / BLOCK_SIZE)
	var cumulative: int = _total_blocks + _local_blocks
	if cumulative == _last_blocks:
		return
	_last_blocks = cumulative

	var gs: Node = get_node_or_null(^"/root/GameState")
	if gs == null:
		return
	if gs.has_method(&"set_distance_blocks"):
		gs.set_distance_blocks(cumulative)

	# Purple projectiles at 18 blocks.
	if cumulative >= purple_distance and not _purple_unlocked:
		_purple_unlocked = true
		if gs.has_method(&"set_boss_phase"):
			gs.set_boss_phase(GameRules.BossPhase.LAND_PURPLE)

	# First water at 28 blocks.
	if cumulative >= first_water_distance and not _first_water_started:
		_trigger_water(&"distance_28")

	# Camera follows player horizontally.
	if _camera != null:
		_camera.global_position.x = _player.global_position.x


# ── Tutorial trigger ──────────────────────────────────────────────────────────

func _on_safe_trigger(_body: Node) -> void:
	if _tutorial_done:
		return
	_tutorial_done = true

	# Completely remove the safe zone from the scene tree.
	if _safe_zone_root != null:
		_safe_zone_root.queue_free()

	# Reveal and activate Boss 67.
	if _boss != null:
		_boss.show()
		_boss.set_process(true)
		_boss.set_physics_process(true)

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


# ── Water ─────────────────────────────────────────────────────────────────────

func _trigger_water(_reason: StringName) -> void:
	var gs: Node = get_node_or_null(^"/root/GameState")
	if gs == null or not gs.has_method(&"begin_water_event"):
		return

	var current_variant: GameRules.WaterVariant = gs.get("water_variant")
	if current_variant != GameRules.WaterVariant.NONE:
		return

	_first_water_started = true

	# Pick a random water variant.
	var variants: Array[GameRules.WaterVariant] = WaterRuleServiceScript.water_variants()
	var chosen_variant: GameRules.WaterVariant = variants[randi() % variants.size()]

	# Pick a random complication (or NONE with equal probability).
	var complication: GameRules.WaterComplication = _pick_complication()

	if gs.has_method(&"set_boss_phase"):
		gs.set_boss_phase(GameRules.BossPhase.WATER)

	gs.begin_water_event(chosen_variant, complication)


func _pick_complication() -> GameRules.WaterComplication:
	# 33% chance each: NONE / REVERSED_CONTROLS / INVERTED_GRAVITY
	var roll: int = randi() % 3
	match roll:
		0:
			return GameRules.WaterComplication.NONE
		1:
			return GameRules.WaterComplication.REVERSED_CONTROLS
		_:
			return GameRules.WaterComplication.INVERTED_GRAVITY


func _on_water_finished() -> void:
	if _first_water_started:
		_first_water_finished = true
		_water_cooldown_left = water_retrigger_cooldown_seconds

	var gs: Node = get_node_or_null(^"/root/GameState")
	if gs == null or not gs.has_method(&"set_boss_phase"):
		return
	var next_phase: GameRules.BossPhase = (
		GameRules.BossPhase.LAND_PURPLE
		if _last_blocks >= purple_distance
		else GameRules.BossPhase.LAND_WHITE
	)
	gs.set_boss_phase(next_phase)


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
	var pickup_units: int = value_cents / 100
	if pickup_units <= 0:
		return
	if pickup_units % 6 == 0 or pickup_units % 7 == 0:
		_trigger_water(&"score_divisible")


# ── Restart ───────────────────────────────────────────────────────────────────

func _on_restart_requested() -> void:
	_cleanup(_pickup_root)
	_cleanup(_projectile_root)
	_tutorial_done        = false
	_first_water_started  = false
	_first_water_finished = false
	_water_cooldown_left  = 0.0
	_last_blocks          = -1
	_total_blocks         = 0
	_local_blocks         = 0
	_purple_unlocked      = false

	# Boss hidden again until tutorial repeats.
	if _boss != null:
		_boss.hide()
		_boss.set_process(false)
		_boss.set_physics_process(false)


# ── Spawn helpers ─────────────────────────────────────────────────────────────

func _spawn_pickup() -> void:
	if _pickup_root == null or score_pickup_scene == null:
		_start_pickup_timer()
		return
	if _pickup_root.get_child_count() >= max_active_pickups:
		_start_pickup_timer()
		return

	var pickup: Node2D = score_pickup_scene.instantiate() as Node2D
	if pickup == null:
		_start_pickup_timer()
		return

	var operations: Array[Dictionary] = _pickup_operations()
	var op_data: Dictionary = operations[randi() % operations.size()]
	pickup.set(&"operation",   op_data["operation"])
	pickup.set(&"value_cents", op_data["value_cents"])

	# Spawn at a random column, either on a block top or 2 units above floor.
	pickup.global_position = _random_pickup_position()
	_pickup_root.add_child(pickup)
	_start_pickup_timer()


func _random_pickup_position() -> Vector2:
	# Pick a column relative to the player's current screen center.
	var player_x: float = _player.global_position.x if _player != null else 0.0
	var half_screen: float = 6.0 * BLOCK_SIZE   # 6 columns each side
	var x: float = player_x - half_screen + randf() * (12.0 * BLOCK_SIZE)
	# Y: either directly on floor (row 7 in 0-indexed) or 2 blocks above floor
	var on_floor: bool = randf() > 0.5
	var y: float = (7.0 * BLOCK_SIZE) if on_floor else (5.0 * BLOCK_SIZE)
	return Vector2(x, y)


func _spawn_projectile() -> void:
	if _projectile_root == null or _boss == null or boss_projectile_scene == null:
		_start_projectile_timer()
		return

	var proj: Node2D = boss_projectile_scene.instantiate() as Node2D
	if proj == null:
		_start_projectile_timer()
		return

	var use_purple: bool = _purple_unlocked and randf() < purple_chance
	var operations: Array[Dictionary] = _boss_operations()
	var op_data: Dictionary = operations[randi() % operations.size()]

	proj.set(&"operation",   op_data["operation"])
	proj.set(&"value_cents", op_data["value_cents"])
	proj.set(&"is_purple",   use_purple)

	# Spawn from the boss position.
	var spawn_pos: Vector2 = _boss.global_position
	if _boss.has_method(&"get_spawn_positions"):
		var positions: Array[Vector2] = _boss.call(&"get_spawn_positions")
		if not positions.is_empty():
			spawn_pos = positions[randi() % positions.size()]

	proj.global_position = spawn_pos
	_projectile_root.add_child(proj)
	_start_projectile_timer()


# ── Timers ────────────────────────────────────────────────────────────────────

func _start_timers() -> void:
	_pickup_timer.start(randf_range(pickup_interval_min, pickup_interval_max))
	_projectile_timer.start(randf_range(projectile_interval_min, projectile_interval_max))


func _start_pickup_timer() -> void:
	_pickup_timer.start(randf_range(pickup_interval_min, pickup_interval_max))


func _start_projectile_timer() -> void:
	var interval_min: float = purple_interval_min if _purple_unlocked else projectile_interval_min
	var interval_max: float = purple_interval_max if _purple_unlocked else projectile_interval_max
	_projectile_timer.start(randf_range(interval_min, interval_max))


# ── Operations ────────────────────────────────────────────────────────────────

func _pickup_operations() -> Array[Dictionary]:
	var gs: Node = get_node_or_null(^"/root/GameState")
	if gs != null:
		var variant: GameRules.WaterVariant = gs.get("water_variant")
		if variant != GameRules.WaterVariant.NONE:
			return WaterRuleServiceScript.floor_operations_for_water(variant)
	return WaterRuleServiceScript.land_pickup_operations()


func _boss_operations() -> Array[Dictionary]:
	var gs: Node = get_node_or_null(^"/root/GameState")
	if gs != null:
		var variant: GameRules.WaterVariant = gs.get("water_variant")
		if variant != GameRules.WaterVariant.NONE:
			return WaterRuleServiceScript.boss_operations_for_water(variant)
	return WaterRuleServiceScript.land_boss_projectile_operations()


# ── Utility ───────────────────────────────────────────────────────────────────

func _update_water_cooldown(delta: float) -> void:
	if _water_cooldown_left <= 0.0:
		return
	_water_cooldown_left = maxf(0.0, _water_cooldown_left - delta)


func _cleanup(node: Node) -> void:
	if node == null:
		return
	for child in node.get_children():
		child.queue_free()
