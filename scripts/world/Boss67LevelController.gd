class_name Boss67LevelController
extends Node

const WaterRuleServiceScript = preload("res://scripts/gameplay/WaterRuleService.gd")

const MAP_COLUMNS: int = 53
const SAFE_ZONE_COLUMNS: int = 18
const FIGHT_START_COLUMN: int = 19
const BLOCK_SIZE: float = 48.0
const FLOOR_TOP_Y: float = 570.0
const SAFE_CAMERA_CENTER_X: float = 288.0
const VIEWPORT_HEIGHT: float = 648.0
const MAP_END_X: float = MAP_COLUMNS * BLOCK_SIZE
const FIGHT_START_X: float = (FIGHT_START_COLUMN - 1) * BLOCK_SIZE
const BOSS_ROUTE_COLUMNS: int = MAP_COLUMNS - SAFE_ZONE_COLUMNS
const WRAP_MARGIN_COLUMNS: int = 12
const WRAP_MARGIN_X: float = WRAP_MARGIN_COLUMNS * BLOCK_SIZE
const PICKUP_VISUAL_HALF_SIZE: Vector2 = Vector2(29.0, 18.0)
const PICKUP_STONE_CLEARANCE: float = 6.0
const PICKUP_SEPARATION: float = 14.0

const AUTHORED_BLOCKS: Array[Vector2i] = [
	

	Vector2i(19, 1),
	Vector2i(21, 3),
	Vector2i(24, 6),#
	Vector2i(25, 5),##
	Vector2i(26, 7),##
	Vector2i(26, 2),
	Vector2i(26, 5),#
	Vector2i(27, 5),#
	Vector2i(27, 7),#
	Vector2i(28, 1),
	Vector2i(28, 4),
	Vector2i(28, 7),#
	Vector2i(30, 6),#
	Vector2i(30, 3),
	Vector2i(31, 6),#
	Vector2i(31, 2),
	Vector2i(32, 2),
	Vector2i(32, 5),
	Vector2i(34, 4),
	Vector2i(34, 1),
	Vector2i(35, 3),#
	Vector2i(37, 3),
	Vector2i(39, 1),
	Vector2i(40, 1),
	Vector2i(40, 2),
	Vector2i(42, 2),#
	Vector2i(43, 2),
	Vector2i(43, 3),
	Vector2i(45, 3),
	Vector2i(45, 5),
	Vector2i(46, 3),
	Vector2i(47, 4),
	Vector2i(48, 3), #
	Vector2i(49, 1),
	Vector2i(50, 1),#
	Vector2i(50, 2),#
	Vector2i(51, 1),#

	Vector2i(1, 1),
	Vector2i(2, 2),
	Vector2i(3, 3),
	Vector2i(3, 7),#
	Vector2i(4, 1),
	Vector2i(5, 6),#
	Vector2i(7, 6),#
	Vector2i(9, 5),
	Vector2i(9, 3),
	Vector2i(10, 3),
	Vector2i(11, 4),
	Vector2i(11, 1),
	Vector2i(12, 3),
	Vector2i(14, 3),
	Vector2i(15, 2),
	Vector2i(17, 1),

	
]

@export_group("Node Paths")
@export var player_path: NodePath
@export var boss_path: NodePath
@export var camera_path: NodePath
@export var safe_wall_path: NodePath
@export var safe_zone_path: NodePath
@export var safe_trigger_path: NodePath
@export var water_overlay_path: NodePath
@export var land_background_path: NodePath
@export var water_background_path: NodePath
@export var pickup_root_path: NodePath
@export var projectile_root_path: NodePath
@export var powerup_root_path: NodePath
@export var terrain_visual_path: NodePath
@export var terrain_path: NodePath

@export_group("Scenes")
@export var score_pickup_scene: PackedScene
@export var boss_projectile_scene: PackedScene
@export var powerup_scene: PackedScene
@export var block_texture: Texture2D

@export_group("Tuning")
@export var purple_distance: int = GameRules.FIRST_PURPLE_DISTANCE_BLOCKS
@export var max_active_pickups: int = 9
@export var initial_pickup_count: int = 7
@export var pickup_interval_min: float = 2.5
@export var pickup_interval_max: float = 5.0
@export var projectile_interval_min: float = 2.0
@export var projectile_interval_max: float = 3.4
@export var purple_interval_min: float = 3.5
@export var purple_interval_max: float = 6.0
@export var shot_gap_seconds: float = 1.0
@export var purple_chance: float = 0.35
@export var first_water_distance: int = GameRules.FIRST_WATER_DISTANCE_BLOCKS
@export var water_retrigger_cooldown_seconds: float = GameRules.WATER_RETRIGGER_COOLDOWN_SECONDS
@export var powerup_interval_min: float = 30.0
@export var powerup_interval_max: float = 60.0
@export var boss_camera_offset: Vector2 = Vector2(250.0, -215.0)

var _player: CharacterBody2D
var _boss: Node2D
var _camera: Camera2D
var _safe_wall: Node
var _safe_zone: Node
var _water_overlay: CanvasItem
var _land_background: CanvasItem
var _water_background: CanvasItem
var _pickup_root: Node2D
var _projectile_root: Node2D
var _powerup_root: Node2D
var _terrain_visual: Node2D
var _terrain: StaticBody2D
var _block_texture: Texture2D

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
var _shot_queue_timer: Timer
var _shot_queue: Array[Dictionary] = []
var _authored_runtime_nodes: Array[Node] = []
var _wrapped_runtime_nodes: Array[Node] = []
var _tutorial_runtime_nodes: Array[Node] = []


func _ready() -> void:
	_player = get_node_or_null(player_path) as CharacterBody2D
	_boss = get_node_or_null(boss_path) as Node2D
	_camera = get_node_or_null(camera_path) as Camera2D
	_safe_wall = get_node_or_null(safe_wall_path)
	_safe_zone = get_node_or_null(safe_zone_path)
	_water_overlay = get_node_or_null(water_overlay_path) as CanvasItem
	_land_background = get_node_or_null(land_background_path) as CanvasItem
	_water_background = get_node_or_null(water_background_path) as CanvasItem
	_pickup_root = get_node_or_null(pickup_root_path) as Node2D
	_projectile_root = get_node_or_null(projectile_root_path) as Node2D
	_powerup_root = get_node_or_null(powerup_root_path) as Node2D
	_terrain_visual = get_node_or_null(terrain_visual_path) as Node2D
	_terrain = get_node_or_null(terrain_path) as StaticBody2D
	_block_texture = block_texture

	_build_authored_blocks()
	_build_tutorial_block()
	_reset_level_visibility()
	_connect_signals()
	_create_timers()


func _process(delta: float) -> void:
	_update_water_cooldown(delta)
	if _player == null:
		return

	_clamp_or_loop_player()
	_update_camera_and_boss()

	if not _tutorial_done:
		return

	_update_distance_and_phase()


func _build_authored_blocks() -> void:
	if not _authored_runtime_nodes.is_empty():
		return
	for block: Vector2i in AUTHORED_BLOCKS:
		_create_block(block.x, block.y, _authored_runtime_nodes)

	for block: Vector2i in AUTHORED_BLOCKS:
		_create_block(block.x + MAP_COLUMNS, block.y, _wrapped_runtime_nodes)
		_create_block(block.x - MAP_COLUMNS, block.y, _wrapped_runtime_nodes)


func _create_block(column: int, row: int, nodes: Array[Node]) -> void:
	var position: Vector2 = _block_position(column, row)
	if _terrain != null:
		var collision_shape := CollisionShape2D.new()
		var rectangle := RectangleShape2D.new()
		rectangle.size = Vector2(BLOCK_SIZE, BLOCK_SIZE)
		collision_shape.shape = rectangle
		collision_shape.position = position
		_terrain.add_child(collision_shape)
		nodes.append(collision_shape)

	if _terrain_visual != null:
		var visual: CanvasItem = _create_block_visual(position)
		_terrain_visual.add_child(visual)
		nodes.append(visual)


func _build_tutorial_block() -> void:
	if not _tutorial_runtime_nodes.is_empty():
		return
	var position: Vector2 = _block_position(13, 1)
	if _terrain != null:
		var collision_shape := CollisionShape2D.new()
		var rectangle := RectangleShape2D.new()
		rectangle.size = Vector2(BLOCK_SIZE, BLOCK_SIZE)
		collision_shape.shape = rectangle
		collision_shape.position = position
		_terrain.add_child(collision_shape)
		_tutorial_runtime_nodes.append(collision_shape)

	if _terrain_visual != null:
		var visual: CanvasItem = _create_block_visual(position)
		_terrain_visual.add_child(visual)
		_tutorial_runtime_nodes.append(visual)


func _block_position(column: int, row: int) -> Vector2:
	return Vector2(
		(column - 1) * BLOCK_SIZE + BLOCK_SIZE * 0.5,
		FLOOR_TOP_Y - (row - 0.5) * BLOCK_SIZE
	)


func _create_block_visual(position: Vector2) -> CanvasItem:
	if _block_texture != null:
		var sprite := Sprite2D.new()
		sprite.texture = _block_texture
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		sprite.position = position
		var texture_size: Vector2 = _block_texture.get_size()
		if texture_size.x > 0.0 and texture_size.y > 0.0:
			sprite.scale = Vector2(BLOCK_SIZE / texture_size.x, BLOCK_SIZE / texture_size.y)
		return sprite

	var fallback := Polygon2D.new()
	var half_size: float = BLOCK_SIZE * 0.5
	fallback.polygon = PackedVector2Array([
		Vector2(-half_size, -half_size),
		Vector2(half_size, -half_size),
		Vector2(half_size, half_size),
		Vector2(-half_size, half_size),
	])
	fallback.color = Color(0.68, 0.48, 0.22, 1.0)
	fallback.position = position
	return fallback

func _wrapped_block_position(column: int, row: int) -> Vector2:
	var base: Vector2 = _block_position(column, row)
	var camera_x: float = _camera.global_position.x if _camera != null else base.x
	var best: Vector2 = base
	var best_dist: float = absf(base.x - camera_x)

	var wrapped: Vector2 = _block_position(column + MAP_COLUMNS, row)
	var dist: float = absf(wrapped.x - camera_x)
	if dist < best_dist:
		best = wrapped
		best_dist = dist

	wrapped = _block_position(column - MAP_COLUMNS, row)
	dist = absf(wrapped.x - camera_x)
	if dist < best_dist:
		best = wrapped

	return best


func _connect_signals() -> void:
	var trigger: Area2D = get_node_or_null(safe_trigger_path) as Area2D
	if trigger != null:
		trigger.body_entered.connect(_on_safe_trigger)

	var game_events: Node = get_node_or_null(^"/root/GameEvents")
	if game_events == null:
		return
	_opt_connect(game_events, &"restart_requested", _on_restart_requested)
	_opt_connect(game_events, &"water_started", _on_water_started)
	_opt_connect(game_events, &"water_finished", _on_water_finished)
	_opt_connect(game_events, &"score_operation_applied", _on_score_operation_applied)


func _opt_connect(source: Node, signal_name: StringName, callback: Callable) -> void:
	if source.has_signal(signal_name) and not source.is_connected(signal_name, callback):
		source.connect(signal_name, callback)


func _create_timers() -> void:
	_pickup_timer = _make_timer(_spawn_pickup)
	_projectile_timer = _make_timer(_queue_volley)
	_powerup_timer = _make_timer(_spawn_powerup)
	_shot_queue_timer = _make_timer(_fire_next_shot)


func _make_timer(callback: Callable) -> Timer:
	var timer := Timer.new()
	timer.one_shot = true
	timer.timeout.connect(callback)
	add_child(timer)
	return timer


func _reset_level_visibility() -> void:
	if _boss != null:
		_boss.hide()
	if _safe_zone != null:
		_safe_zone.show()
	if _safe_wall != null:
		_safe_wall.hide()
		_set_node_tree_collision_enabled(_safe_wall, false)
	if _camera != null:
		_camera.zoom = Vector2.ONE
	if _water_overlay != null:
		_water_overlay.hide()
	if _land_background != null:
		_land_background.show()
	if _water_background != null:
		_water_background.hide()
	_set_runtime_nodes_enabled(_authored_runtime_nodes, false)
	_set_runtime_nodes_enabled(_wrapped_runtime_nodes, false)
	_set_runtime_nodes_enabled(_tutorial_runtime_nodes, true)


func _clamp_or_loop_player() -> void:
	if _player == null:
		return

	if not _tutorial_done:
		_player.global_position.x = clampf(_player.global_position.x, 24.0, FIGHT_START_X - 12.0)
		return

	if _player.global_position.x < -WRAP_MARGIN_X:
		_player.global_position.x += MAP_END_X
		if _camera != null:
			_camera.global_position.x += MAP_END_X
			_camera.reset_smoothing()
	if _player.global_position.x >= MAP_END_X + WRAP_MARGIN_X:
		_player.global_position.x -= MAP_END_X
		_total_blocks += MAP_COLUMNS
		if _camera != null:
			_camera.global_position.x -= MAP_END_X
			_camera.reset_smoothing()


func _update_camera_and_boss() -> void:
	if _camera == null or _player == null:
		return

	_camera.zoom = Vector2.ONE
	var camera_x: float = _player.global_position.x if _tutorial_done else SAFE_CAMERA_CENTER_X
	_camera.global_position = Vector2(camera_x, VIEWPORT_HEIGHT * 0.5)

	if _tutorial_done and _boss != null:
		_boss.global_position = _camera.global_position + boss_camera_offset


func _update_distance_and_phase() -> void:
	_local_blocks = maxi(0, int((_player.global_position.x - FIGHT_START_X) / BLOCK_SIZE))
	var cumulative_blocks: int = _total_blocks + _local_blocks
	if cumulative_blocks == _last_blocks:
		return
	_last_blocks = cumulative_blocks

	var game_state: Node = get_node_or_null(^"/root/GameState")
	if game_state == null:
		return
	if game_state.has_method(&"set_distance_blocks"):
		game_state.set_distance_blocks(cumulative_blocks)
	if cumulative_blocks >= purple_distance and not _purple_unlocked:
		_purple_unlocked = true
		if game_state.has_method(&"set_boss_phase"):
			game_state.set_boss_phase(GameRules.BossPhase.LAND_PURPLE)
	if cumulative_blocks >= first_water_distance and not _first_water_started:
		_trigger_water(&"distance_28")


func _on_safe_trigger(_body: Node) -> void:
	if _tutorial_done:
		return
	_tutorial_done = true

	if _safe_zone != null:
		_safe_zone.hide()
	_set_runtime_nodes_enabled(_tutorial_runtime_nodes, false)
	_set_runtime_nodes_enabled(_authored_runtime_nodes, true)
	_set_runtime_nodes_enabled(_wrapped_runtime_nodes, true)
	if _boss != null:
		_boss.show()

	var game_state: Node = get_node_or_null(^"/root/GameState")
	if game_state != null:
		_total_blocks = 0
		_local_blocks = 0
		_last_blocks = 0
		if game_state.has_method(&"set_distance_blocks"):
			game_state.set_distance_blocks(0)
		if game_state.has_method(&"set_boss_phase"):
			game_state.set_boss_phase(GameRules.BossPhase.LAND_WHITE)

	call_deferred("_seed_pickups")
	call_deferred("_start_timers")


func _seed_pickups() -> void:
	for _index: int in range(mini(initial_pickup_count, max_active_pickups)):
		_spawn_pickup(false)


func _queue_volley() -> void:
	if _boss == null or _projectile_root == null or boss_projectile_scene == null:
		_start_projectile_timer()
		return
	if _player == null or not _tutorial_done:
		_start_projectile_timer()
		return

	var use_purple: bool = _purple_unlocked and randf() < purple_chance
	var operations: Array[Dictionary] = _boss_operations()
	var flank_offset: float = -96.0 if randf() < 0.5 else 96.0
	var offsets: Array[float] = [0.0, flank_offset]
	offsets.shuffle()

	_shot_queue.clear()
	for offset: float in offsets:
		var operation_data: Dictionary = _pick_boss_operation(operations)
		_shot_queue.append({
			"operation": operation_data["operation"],
			"value_cents": operation_data["value_cents"],
			"purple": use_purple,
			"target": Vector2(_player.global_position.x + offset, _player.global_position.y),
		})

	_fire_next_shot()
	_start_projectile_timer()


func _spawn_projectile() -> void:
	_queue_volley()


func _fire_next_shot() -> void:
	if _shot_queue.is_empty():
		return
	_fire_projectile(_shot_queue.pop_front())
	if not _shot_queue.is_empty():
		_shot_queue_timer.start(shot_gap_seconds)


func _fire_projectile(data: Dictionary) -> void:
	var projectile: Node2D = boss_projectile_scene.instantiate() as Node2D
	if projectile == null:
		return

	projectile.set(&"operation", data["operation"])
	projectile.set(&"value_cents", data["value_cents"])
	projectile.set(&"is_purple", data["purple"])

	var spawn: Vector2 = _boss.global_position if _boss != null else Vector2.ZERO
	var target: Vector2 = data["target"]
	var direction: Vector2 = (target - spawn).normalized()
	if projectile.has_method(&"set_direction"):
		projectile.call(&"set_direction", direction)
	else:
		projectile.set(&"_direction", direction)

	projectile.global_position = spawn
	_projectile_root.add_child(projectile)


func _pick_boss_operation(operations: Array[Dictionary]) -> Dictionary:
	var safe_operations: Array[Dictionary] = []
	var zero_operation: Dictionary = {}
	for operation_data: Dictionary in operations:
		if operation_data.get("operation") == GameRules.SCORE_OPERATION_MULTIPLY \
				and operation_data.get("value_cents") == 0:
			zero_operation = operation_data
		else:
			safe_operations.append(operation_data)
	if not zero_operation.is_empty() and randf() < 0.05:
		return zero_operation
	if not safe_operations.is_empty():
		return safe_operations[randi() % safe_operations.size()]
	return operations[randi() % operations.size()]


func _spawn_pickup(restart_timer: bool = true) -> void:
	if _pickup_root == null or score_pickup_scene == null:
		if restart_timer:
			_start_pickup_timer()
		return
	if _pickup_root.get_child_count() >= max_active_pickups:
		if restart_timer:
			_start_pickup_timer()
		return

	var pickup: Node2D = score_pickup_scene.instantiate() as Node2D
	if pickup == null:
		if restart_timer:
			_start_pickup_timer()
		return

	var operations: Array[Dictionary] = _pickup_operations()
	var operation_data: Dictionary = operations[randi() % operations.size()]
	pickup.set(&"operation", operation_data["operation"])
	pickup.set(&"value_cents", operation_data["value_cents"])
	var spawn_position: Vector2 = _random_pickup_position()
	if not spawn_position.is_finite():
		pickup.queue_free()
		if restart_timer:
			_start_pickup_timer()
		return
	pickup.global_position = spawn_position
	_pickup_root.add_child(pickup)

	if restart_timer:
		_start_pickup_timer()


func _random_pickup_position() -> Vector2:
	var candidates: Array[Vector2i] = _visible_blocks(false)
	var high_candidates: Array[Vector2i] = _visible_blocks(true)
	candidates.shuffle()
	high_candidates.shuffle()

	var preferred: Array[Vector2i] = high_candidates if (
		not high_candidates.is_empty() and randf() < 0.45
	) else candidates
	for block: Vector2i in preferred:
		var position: Vector2 = _pickup_position_for_block(block)
		if _is_pickup_position_clear(position):
			return position

	for block: Vector2i in candidates:
		var position: Vector2 = _pickup_position_for_block(block)
		if _is_pickup_position_clear(position):
			return position

	return _find_clear_air_position()


func _pickup_position_for_block(block: Vector2i) -> Vector2:
	var base: Vector2 = _wrapped_block_position(block.x, block.y)
	var extra_height: float = 1.55 if block.y >= 4 else 1.4
	return _clamp_pickup_position(Vector2(base.x, base.y - BLOCK_SIZE * extra_height))


func _find_clear_air_position() -> Vector2:
	var camera_x: float = _camera.global_position.x if _camera != null else FIGHT_START_X
	if _tutorial_done:
		camera_x = maxf(camera_x, FIGHT_START_X + 288.0)
	var horizontal_offsets: Array[float] = [
		-384.0, -288.0, -192.0, -96.0, 0.0, 96.0, 192.0, 288.0, 384.0, 480.0
	]
	var heights: Array[float] = [2.0, 3.25, 4.5, 5.75]
	horizontal_offsets.shuffle()
	heights.shuffle()

	for height: float in heights:
		for offset: float in horizontal_offsets:
			var position := Vector2(
				clampf(
					camera_x + offset,
					-WRAP_MARGIN_X + 24.0,
					MAP_END_X + WRAP_MARGIN_X - 24.0
				),
				FLOOR_TOP_Y - BLOCK_SIZE * height
			)
			if _is_pickup_position_clear(position):
				return position

	return Vector2.INF


func _is_pickup_position_clear(position: Vector2) -> bool:
	if not position.is_finite():
		return false
	var pickup_rect := Rect2(
		position - PICKUP_VISUAL_HALF_SIZE,
		PICKUP_VISUAL_HALF_SIZE * 2.0
	).grow(PICKUP_STONE_CLEARANCE)
	if pickup_rect.end.y >= FLOOR_TOP_Y:
		return false

	var block_size := Vector2(BLOCK_SIZE, BLOCK_SIZE)
	for block: Vector2i in AUTHORED_BLOCKS:
		for column_offset: int in [-MAP_COLUMNS, 0, MAP_COLUMNS]:
			var block_center: Vector2 = _block_position(block.x + column_offset, block.y)
			var block_rect := Rect2(block_center - block_size * 0.5, block_size)
			if pickup_rect.intersects(block_rect):
				return false

	if _pickup_root != null:
		var separation_size: Vector2 = PICKUP_VISUAL_HALF_SIZE + Vector2.ONE * PICKUP_SEPARATION
		var separation_rect := Rect2(position - separation_size, separation_size * 2.0)
		for child: Node in _pickup_root.get_children():
			var active_pickup: Node2D = child as Node2D
			if active_pickup == null or active_pickup.is_queued_for_deletion():
				continue
			var active_rect := Rect2(
				active_pickup.global_position - PICKUP_VISUAL_HALF_SIZE,
				PICKUP_VISUAL_HALF_SIZE * 2.0
			)
			if separation_rect.intersects(active_rect):
				return false
	return true


func _clamp_pickup_position(position: Vector2) -> Vector2:
	position.y = minf(position.y, FLOOR_TOP_Y - BLOCK_SIZE * 1.15)
	return position


func _visible_blocks(high_only: bool) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	var camera_x: float = _camera.global_position.x if _camera != null else FIGHT_START_X
	var left_edge: float = camera_x - 360.0
	var right_edge: float = camera_x + 620.0
	for block: Vector2i in AUTHORED_BLOCKS:
		if block.x < FIGHT_START_COLUMN:
			continue
		if high_only and block.y < 4:
			continue
		if AUTHORED_BLOCKS.has(Vector2i(block.x, block.y + 1)):
			continue
		if _block_visible(block.x, block.y, left_edge, right_edge):
			result.append(block)
	return result


func _block_visible(column: int, row: int, left: float, right: float) -> bool:
	var x: float = _block_position(column, row).x
	if x >= left and x <= right:
		return true
	x = _block_position(column + MAP_COLUMNS, row).x
	if x >= left and x <= right:
		return true
	x = _block_position(column - MAP_COLUMNS, row).x
	if x >= left and x <= right:
		return true
	return false


func _spawn_powerup() -> void:
	if _powerup_root == null or powerup_scene == null:
		_start_powerup_timer()
		return
	if _powerup_root.get_child_count() > 0:
		_start_powerup_timer()
		return

	var powerup: Node2D = powerup_scene.instantiate() as Node2D
	if powerup == null:
		_start_powerup_timer()
		return

	var kinds: Array[StringName] = [GameRules.POWERUP_SLOW, GameRules.POWERUP_DOUBLE_JUMP]
	powerup.set(&"kind", kinds[randi() % kinds.size()])
	powerup.set(&"duration_seconds", GameRules.POWERUP_DURATION_SECONDS)
	var spawn_position: Vector2 = _random_powerup_position()
	if not spawn_position.is_finite():
		powerup.queue_free()
		_start_powerup_timer()
		return
	powerup.global_position = spawn_position
	_powerup_root.add_child(powerup)
	_start_powerup_timer()


func _random_powerup_position() -> Vector2:
	var high_candidates: Array[Vector2i] = _visible_blocks(true)
	if high_candidates.is_empty():
		var camera_x: float = _camera.global_position.x if _camera != null else FIGHT_START_X
		return Vector2(camera_x + 260.0, FLOOR_TOP_Y - BLOCK_SIZE * 3.5)

	var block: Vector2i = high_candidates[randi() % high_candidates.size()]
	var base: Vector2 = _wrapped_block_position(block.x, block.y)
	var position := Vector2(base.x, base.y - BLOCK_SIZE * 1.55)
	return position if _is_pickup_position_clear(position) else _find_clear_air_position()


func _trigger_water(_reason: StringName) -> void:
	var game_state: Node = get_node_or_null(^"/root/GameState")
	if game_state == null or not game_state.has_method(&"begin_water_event"):
		return
	if game_state.get("water_variant") != GameRules.WaterVariant.NONE:
		return

	_first_water_started = true
	var variants: Array[GameRules.WaterVariant] = WaterRuleServiceScript.water_variants()
	var variant: GameRules.WaterVariant = variants[randi() % variants.size()]
	var complication: GameRules.WaterComplication = _pick_complication()

	if game_state.has_method(&"set_boss_phase"):
		game_state.set_boss_phase(GameRules.BossPhase.WATER)
	game_state.begin_water_event(variant, complication)


func _pick_complication() -> GameRules.WaterComplication:
	if randi() % 2 == 0:
		return GameRules.WaterComplication.REVERSED_CONTROLS
	return GameRules.WaterComplication.INVERTED_GRAVITY


func _on_water_started(
	_variant: GameRules.WaterVariant,
	complication: GameRules.WaterComplication,
	_seconds: float
) -> void:
	if _water_overlay != null:
		_water_overlay.show()
	if _land_background != null:
		_land_background.hide()
	if _water_background != null:
		_water_background.show()
	_set_world_flipped(complication == GameRules.WaterComplication.INVERTED_GRAVITY)


func _on_water_finished() -> void:
	if _water_overlay != null:
		_water_overlay.hide()
	if _land_background != null:
		_land_background.show()
	if _water_background != null:
		_water_background.hide()
	_set_world_flipped(false)

	if _first_water_started:
		_first_water_finished = true
		_water_cooldown_left = water_retrigger_cooldown_seconds

	var game_state: Node = get_node_or_null(^"/root/GameState")
	if game_state == null or not game_state.has_method(&"set_boss_phase"):
		return
	var next_phase: GameRules.BossPhase = (
		GameRules.BossPhase.LAND_PURPLE
		if _last_blocks >= purple_distance
		else GameRules.BossPhase.LAND_WHITE
	)
	game_state.set_boss_phase(next_phase)


func _set_world_flipped(flipped: bool) -> void:
	if _camera != null:
		_camera.ignore_rotation = false
		_camera.rotation = PI if flipped else 0.0


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
	var game_state: Node = get_node_or_null(^"/root/GameState")
	if game_state == null:
		return
	var score_units: int = int(roundi(game_state.get("score_cents") / 100.0))
	if score_units > 0 and (score_units % 6 == 0 or score_units % 7 == 0):
		_trigger_water(&"score_divisible")


func _on_restart_requested() -> void:
	_stop_timers()
	_cleanup(_pickup_root)
	_cleanup(_projectile_root)
	_cleanup(_powerup_root)
	_shot_queue.clear()
	_tutorial_done = false
	_first_water_started = false
	_first_water_finished = false
	_water_cooldown_left = 0.0
	_last_blocks = -1
	_total_blocks = 0
	_local_blocks = 0
	_purple_unlocked = false
	_set_world_flipped(false)
	if _player != null:
		_player.global_position = Vector2(60.0, 555.0)
		_player.velocity = Vector2.ZERO
		_player.modulate = Color.WHITE
		_player.show()
		if _player.has_method(&"apply_phase"):
			_player.apply_phase(GameRules.Phase.LAND)
	_reset_level_visibility()


func _start_timers() -> void:
	_start_pickup_timer()
	_start_projectile_timer()
	_start_powerup_timer()


func _stop_timers() -> void:
	for timer: Timer in [_pickup_timer, _projectile_timer, _powerup_timer, _shot_queue_timer]:
		if timer != null:
			timer.stop()


func _start_pickup_timer() -> void:
	_pickup_timer.start(randf_range(pickup_interval_min, pickup_interval_max))


func _start_projectile_timer() -> void:
	var minimum: float = purple_interval_min if _purple_unlocked else projectile_interval_min
	var maximum: float = purple_interval_max if _purple_unlocked else projectile_interval_max
	_projectile_timer.start(randf_range(minimum, maximum))


func _start_powerup_timer() -> void:
	_powerup_timer.start(randf_range(powerup_interval_min, powerup_interval_max))


func _pickup_operations() -> Array[Dictionary]:
	var game_state: Node = get_node_or_null(^"/root/GameState")
	if game_state != null:
		var variant: GameRules.WaterVariant = game_state.get("water_variant")
		if variant != GameRules.WaterVariant.NONE:
			return WaterRuleServiceScript.floor_operations_for_water(variant)
	return WaterRuleServiceScript.land_pickup_operations()


func _boss_operations() -> Array[Dictionary]:
	var game_state: Node = get_node_or_null(^"/root/GameState")
	if game_state != null:
		var variant: GameRules.WaterVariant = game_state.get("water_variant")
		if variant != GameRules.WaterVariant.NONE:
			return WaterRuleServiceScript.boss_operations_for_water(variant)
	return WaterRuleServiceScript.land_boss_projectile_operations()


func _update_water_cooldown(delta: float) -> void:
	if _water_cooldown_left > 0.0:
		_water_cooldown_left = maxf(0.0, _water_cooldown_left - delta)


func _cleanup(node: Node) -> void:
	if node == null:
		return
	for child: Node in node.get_children():
		child.queue_free()


func _set_runtime_nodes_enabled(nodes: Array[Node], enabled: bool) -> void:
	for node: Node in nodes:
		if not is_instance_valid(node):
			continue
		var shape: CollisionShape2D = node as CollisionShape2D
		if shape != null:
			shape.set_deferred(&"disabled", not enabled)
			continue
		var canvas_item: CanvasItem = node as CanvasItem
		if canvas_item != null:
			canvas_item.visible = enabled


func _set_node_tree_collision_enabled(node: Node, enabled: bool) -> void:
	for child: Node in node.get_children():
		var shape: CollisionShape2D = child as CollisionShape2D
		if shape != null:
			shape.set_deferred(&"disabled", not enabled)
		_set_node_tree_collision_enabled(child, enabled)
