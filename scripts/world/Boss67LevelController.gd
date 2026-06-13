class_name Boss67LevelController
extends Node

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

@export_group("Scenes")
@export var score_pickup_scene: PackedScene
@export var boss_projectile_scene: PackedScene

var _player: Node2D
var _boss: Boss67
var _camera: Camera2D
var _safe_wall: StaticBody2D
var _pickup_root: Node2D
var _projectile_root: Node2D
var _pickup_spawns: Node2D
var _tutorial_done: bool = false
var _water_triggered: bool = false
var _last_blocks: int = -1

var _pickup_timer: Timer
var _projectile_timer: Timer


func _ready() -> void:
	_player = get_node_or_null(player_path) as Node2D
	_boss = get_node_or_null(boss_path) as Boss67
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

	var water: Area2D = get_node_or_null(water_trigger_path) as Area2D
	if water != null:
		water.body_entered.connect(_on_water_trigger)

	var ge: Node = get_node_or_null(^"/root/GameEvents")
	if ge != null and ge.has_signal(&"restart_requested"):
		ge.restart_requested.connect(_on_restart_requested)


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
	if _camera != null and _player != null:
		var target_x: float = maxf(_player.global_position.x, 576.0)
		_camera.global_position = Vector2(target_x, 324.0)

	if _player == null or not _tutorial_done:
		return

	var blocks: int = maxi(0, int((_player.global_position.x - tutorial_end_x) / block_size))
	if blocks == _last_blocks:
		return
	_last_blocks = blocks

	var gs: Node = get_node_or_null(^"/root/GameState")
	if gs == null:
		return
	if gs.has_method(&"set_distance_blocks"):
		gs.set_distance_blocks(blocks)
	if blocks >= purple_distance and gs.has_method(&"set_boss_phase"):
		gs.set_boss_phase(GameRules.BossPhase.LAND_PURPLE)
	if blocks >= 28 and not _water_triggered:
		_trigger_water()


func _on_safe_trigger(_body: Node) -> void:
	if _tutorial_done:
		return
	_tutorial_done = true

	if _safe_wall != null:
		_safe_wall.show()
		_set_wall_collision(true)

	var gs: Node = get_node_or_null(^"/root/GameState")
	if gs != null:
		_last_blocks = 0
		if gs.has_method(&"set_distance_blocks"):
			gs.set_distance_blocks(0)
		if gs.has_method(&"set_boss_phase"):
			gs.set_boss_phase(GameRules.BossPhase.LAND_WHITE)

	_start_timers()


func _on_water_trigger(_body: Node) -> void:
	if _water_triggered:
		return
	_trigger_water()


func _trigger_water() -> void:
	if _water_triggered:
		return
	_water_triggered = true
	var gs: Node = get_node_or_null(^"/root/GameState")
	if gs != null and gs.has_method(&"begin_water_event"):
		gs.begin_water_event(GameRules.WaterVariant.WATER_A, GameRules.WaterComplication.NONE)


func _on_restart_requested() -> void:
	_cleanup(_pickup_root)
	_cleanup(_projectile_root)
	_tutorial_done = false
	_water_triggered = false
	_last_blocks = -1

	if _safe_wall != null:
		_safe_wall.hide()
		_set_wall_collision(false)


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

	var pickup: ScorePickup = score_pickup_scene.instantiate() as ScorePickup
	if pickup == null:
		_start_pickup_timer()
		return

	var values: Array[int] = GameRules.LAND_PICKUP_VALUES_CENTS
	pickup.value_cents = values[randi() % values.size()]
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

	var spawn_positions: Array[Vector2] = _boss.get_spawn_positions()
	if spawn_positions.is_empty():
		_start_projectile_timer()
		return

	var proj: BossProjectile = boss_projectile_scene.instantiate() as BossProjectile
	if proj == null:
		_start_projectile_timer()
		return

	var multipliers: Array[int] = GameRules.LAND_BOSS_MULTIPLIERS_CENTS
	proj.value_cents = multipliers[randi() % multipliers.size()]
	proj.is_purple = _last_blocks >= purple_distance and randf() < purple_chance
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
			shape.disabled = not enabled


func _cleanup(node: Node) -> void:
	if node == null:
		return
	for child in node.get_children():
		child.queue_free()
