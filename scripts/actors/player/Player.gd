class_name Player
extends CharacterBody2D

signal movement_started
signal movement_stopped
signal reset_completed

@export var move_speed: float = GameRules.PLAYER_SPEED
@export var acceleration: float = 2200.0
@export var friction: float = 2600.0
@export var use_acceleration: bool = true
@export var respect_game_state_input: bool = true
@export var land_visual_path: NodePath = ^"LandVisual"
@export var water_visual_path: NodePath = ^"WaterVisual"

var input_enabled: bool = true
var spawn_position: Vector2 = Vector2.ZERO
var current_phase: GameRules.Phase = GameRules.Phase.LAND

var _land_visual: CanvasItem = null
var _water_visual: CanvasItem = null
var _was_moving: bool = false


func _ready() -> void:
	spawn_position = global_position
	_land_visual = get_node_or_null(land_visual_path) as CanvasItem
	_water_visual = get_node_or_null(water_visual_path) as CanvasItem
	_connect_game_events()
	_apply_phase_visuals(current_phase)


func _physics_process(delta: float) -> void:
	var input_direction: Vector2 = _read_move_input()
	_update_velocity(input_direction, delta)
	move_and_slide()
	_emit_movement_state()


func set_input_enabled(enabled: bool) -> void:
	input_enabled = enabled
	if not input_enabled:
		velocity = Vector2.ZERO
		_emit_movement_state()


func apply_phase(phase: GameRules.Phase) -> void:
	current_phase = phase
	_apply_phase_visuals(phase)


func reset_player(new_spawn_position: Variant = null) -> void:
	if new_spawn_position is Vector2:
		spawn_position = new_spawn_position

	global_position = spawn_position
	velocity = Vector2.ZERO
	input_enabled = true
	_was_moving = false
	_apply_phase_visuals(current_phase)
	reset_completed.emit()


func _read_move_input() -> Vector2:
	if not _can_accept_input():
		return Vector2.ZERO
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")


func _can_accept_input() -> bool:
	if not input_enabled:
		return false
	if not respect_game_state_input:
		return true

	var game_state: Node = get_node_or_null(^"/root/GameState")
	if game_state == null:
		return true

	var game_state_input: Variant = game_state.get("input_enabled")
	if game_state_input is bool:
		return game_state_input
	return true


func _update_velocity(input_direction: Vector2, delta: float) -> void:
	var target_velocity: Vector2 = input_direction * move_speed
	if not use_acceleration:
		velocity = target_velocity
		return

	var rate: float = acceleration if input_direction.length_squared() > 0.0 else friction
	velocity = velocity.move_toward(target_velocity, rate * delta)


func _emit_movement_state() -> void:
	var is_moving: bool = velocity.length_squared() > 1.0
	if is_moving == _was_moving:
		return

	_was_moving = is_moving
	if is_moving:
		movement_started.emit()
	else:
		movement_stopped.emit()


func _connect_game_events() -> void:
	var game_events: Node = get_node_or_null(^"/root/GameEvents")
	if game_events == null:
		return
	if not game_events.has_signal(&"phase_changed"):
		return

	var phase_callable: Callable = Callable(self, "_on_phase_changed")
	if not game_events.is_connected(&"phase_changed", phase_callable):
		game_events.connect(&"phase_changed", phase_callable)


func _apply_phase_visuals(phase: GameRules.Phase) -> void:
	var in_water: bool = phase == GameRules.Phase.WATER or phase == GameRules.Phase.COMPLETE
	if _land_visual != null:
		_land_visual.visible = not in_water
	if _water_visual != null:
		_water_visual.visible = in_water


func _on_phase_changed(phase: GameRules.Phase) -> void:
	apply_phase(phase)
