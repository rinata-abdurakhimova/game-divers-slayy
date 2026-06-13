class_name Boss67LevelController
extends Node

const WaterRuleServiceScript = preload("res://scripts/gameplay/WaterRuleService.gd")
const LOOP_WIDTH_BLOCKS: int = 52
const LOOP_WIDTH_PX: float = 52.0 * 48.0

@export_group("Node Paths")
@export var player_path: NodePath
@export var boss_path: NodePath
@export var camera_path: NodePath
@export var safe_wall_path: NodePath
@export var safe_trigger_path: NodePath
@export var water_trigger_path: NodePath
@export var pickup_root_path: NodePath
@export var projectile_root_path: NodePath
@export var pickup_spawns_path: NodePath

@export_group("Tuning")
@export var block_size: float = 48.0
@export var tutorial_end_x: float = 576.0
@export var purple_distance: int = 18
@export var max_active_pickups: int = 7
@export var pickup_interval_min: float = 2.0
@export var pickup_interval_max: float = 4.0
@export var projectile_interval_min: float = 0.8
@export var projectile_interval_max: float = 2.0
@export var purple_chance: float = 0.3
@export var first_water_distance: int = GameRules.FIRST_WATER_DISTANCE_BLOCKS
@export var water_retrigger_cooldown_seconds: float = GameRules.WATER_RETRIGGER_COOLDOWN_SECONDS

@export_group("Scenes")
@export var score_pickup_scene: PackedScene
@export var boss_projectile_scene: PackedScene

var _player: Node2D
var _boss: Node2D
var _camera: Camera2D
var _safe_wall: StaticBody2D
var _pickup_root: Node2D
var _projectile_root: Node2D
var _pickup_spawns: Node2D
var _tutorial_done: bool = false
var _first_water_started: bool = false
var _first_water_finished: bool = false
var _water_cooldown_left: float = 0.0
var _last_blocks: int = -1

var _pickup_timer: Timer
var _projectile_timer: Timer

var _total_blocks: int = 0
var _local_blocks: int = 0
var _purple_unlocked: bool = false


func _ready() -> void:
	_player = get_node_or_null(player_path) as Node2D
	_boss = get_node_or_null(boss_path) as Node2D
	_camera = get_node_or_null(camera_path) as Camera2D
	_safe_wall = get_node_or_null(safe_wall_path) as StaticBody2D
	_pickup_root = get_node_or_null(pickup_root_path) as Node2D
	_projectile_root = get_node_or_null(projectile_root_path) as Node2D
	_pickup_spawns = get_node_or_null(pickup_spawns_path) as Node2D

	if _safe_wall != null:
		_safe_wall.hide()
		_set_wall_collision(false)

	_connect_signals()
	_create_timers()


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


func _process(delta: float) -> void:
	_update_water_cooldown(delta)

	if _camera != null and _player != null:
		var target_x: float = maxf(_player.global_position.x, 576.0)
		_camera.global_position = Vector2(target_x, 324.0)

	if _player == null or not _tutorial_done:
		return

	if _player.global_position.x >= tutorial_end_x + LOOP_WIDTH_PX:
		_wrap_player()

	_local_blocks = maxi(0, int((_player.global_position.x - tutorial_end_x) / block_size))
	var cumulative: int = _total_blocks + _local_blocks
	if cumulative == _last_blocks:
		return
	_last_blocks = cumulative

	var gs: Node = get_node_or_null(^"/root/GameState")
	if gs == null:
		return
	if gs.has_method(&"set_distance_blocks"):
		gs.set_distance_blocks(cumulative)
	if cumulative >= purple_distance and not _purple_unlocked and gs.has_method(&"set_boss_phase"):
		_purple_unlocked = true
		gs.set_boss_phase(GameRules.BossPhase.LAND_PURPLE)
	if cumulative >= first_water_distance and not _first_water_started:
		_trigger_water(&"distance_28")


func _wrap_player() -> void:
	if _player == null:
		return
	_player.global_position.x -= LOOP_WIDTH_PX
	_total_blocks += LOOP_WIDTH_BLOCKS


func _on_safe_trigger(_body: Node) -> void:
	if _tutorial_done:
		return
	_tutorial_done = true

	if _safe_wall != null:
		_safe_wall.show()
		_set_wall_collision(true)

	var gs: Node = get_node_or_null(^"/root/GameState")
	if gs != null:
		_total_blocks = 0
		_local_blocks = 0
		_last_blocks = 0
		if gs.has_method(&"set_distance_blocks"):
			gs.set_distance_blocks(0)
		if gs.has_method(&"set_boss_phase"):
			gs.set_boss_phase(GameRules.BossPhase.LAND_WHITE)

	_start_timers()


func _trigger_water(_reason: StringName) -> void:
	var gs: Node = get_node_or_null(^"/root/GameState")
	if gs == null or not gs.has_method(&"begin_water_event"):
		return

	var current_water_variant: GameRules.WaterVariant = gs.get("water_variant")
	if current_water_variant != GameRules.WaterVariant.NONE:
		return

	_first_water_started = true
	if gs.has_method(&"set_boss_phase"):
		gs.set_boss_phase(GameRules.BossPhase.WATER)
	gs.begin_water_event(GameRules.WaterVariant.WATER_A, GameRules.WaterComplication.NONE)


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


func _on_restart_requested() -> void:
	_cleanup(_pickup_root)
	_cleanup(_projectile_root)
	_tutorial_done = false
	_first_water_started = false
	_first_water_finished = false
	_water_cooldown_left = 0.0
	_last_blocks = -1
	_total_blocks = 0
	_local_blocks = 0
	_purple_unlocked = false

	if _safe_wall != null:
		_safe_wall.hide()
		_set_wall_collision(false)


func _update_water_cooldown(delta: float) -> void:
	if _water_cooldown_left <= 0.0:
		return
	_water_cooldown_left = maxf(0.0, _water_cooldown_left - delta)


func _spawn_pickup() -> void:
	if _pickup_root == null or _pickup_spawns == null or score_pickup_scene == null:
		_start_pickup_timer()
		return
	if _pickup_root.get_child_count() >= max_active_pickups:
		_start_pickup_timer()
		return

	var spawns: Array[Node] = _pickup_spawns.get_children()
	if spawns.is_empty():
		_start_pickup_timer()
		return

	var marker: Marker2D = spawns[randi() % spawns.size()] as Marker2D
	if marker == null:
		_start_pickup_timer()
		return

	var pickup: Node2D = score_pickup_scene.instantiate() as Node2D
	if pickup == null:
		_start_pickup_timer()
		return

	var operations: Array[Dictionary] = _pickup_operations()
	var operation_data: Dictionary = operations[randi() % operations.size()]
	pickup.set(&"operation", operation_data["operation"])
	pickup.set(&"value_cents", operation_data["value_cents"])
	pickup.global_position = marker.global_position
	_pickup_root.add_child(pickup)
	_start_pickup_timer()


func _spawn_projectile() -> void:
	if _projectile_root == null or _boss == null or boss_projectile_scene == null:
		_start_projectile_timer()
		return
	if _last_blocks < 0:
		_start_projectile_timer()
		return

	if not _boss.has_method(&"get_spawn_positions"):
		_start_projectile_timer()
		return
	var spawn_positions: Array[Vector2] = _boss.call(&"get_spawn_positions")
	if spawn_positions.is_empty():
		_start_projectile_timer()
		return

	var proj: Node2D = boss_projectile_scene.instantiate() as Node2D
	if proj == null:
		_start_projectile_timer()
		return

	var operations: Array[Dictionary] = _boss_operations()
	var operation_data: Dictionary = operations[randi() % operations.size()]
	proj.set(&"operation", operation_data["operation"])
	proj.set(&"value_cents", operation_data["value_cents"])
	proj.set(&"is_purple", _last_blocks >= purple_distance and randf() < purple_chance)
	proj.global_position = spawn_positions[randi() % spawn_positions.size()]
	_projectile_root.add_child(proj)
	_start_projectile_timer()


func _start_timers() -> void:
	_pickup_timer.start(randf_range(pickup_interval_min, pickup_interval_max))
	_projectile_timer.start(randf_range(projectile_interval_min, projectile_interval_max))


func _start_pickup_timer() -> void:
	_pickup_timer.start(randf_range(pickup_interval_min, pickup_interval_max))


func _start_projectile_timer() -> void:
	_projectile_timer.start(randf_range(projectile_interval_min, projectile_interval_max))


func _set_wall_collision(enabled: bool) -> void:
	if _safe_wall == null:
		return
	for child in _safe_wall.get_children():
		var shape: CollisionShape2D = child as CollisionShape2D
		if shape != null:
			shape.set_deferred(&"disabled", not enabled)


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


func _cleanup(node: Node) -> void:
	if node == null:
		return
	for child in node.get_children():
		child.queue_free()
