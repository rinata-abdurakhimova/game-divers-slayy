extends CharacterBody2D
class_name PolinaPlayerController2D

signal movement_started
signal movement_stopped
signal action_requested
signal reset_completed

@export var move_speed: float = 240.0
@export var acceleration: float = 2200.0
@export var friction: float = 2600.0
@export var use_acceleration: bool = true
@export var face_movement_direction: bool = false

var input_enabled: bool = true
var spawn_position: Vector2
var last_move_direction: Vector2 = Vector2.DOWN
var _was_moving: bool = false


func _ready() -> void:
	spawn_position = global_position


func _physics_process(delta: float) -> void:
	var input_direction: Vector2 = _read_move_input()
	_update_last_direction(input_direction)
	_update_velocity(input_direction, delta)
	move_and_slide()
	_emit_movement_state()


func set_input_enabled(enabled: bool) -> void:
	input_enabled = enabled
	if not input_enabled:
		velocity = Vector2.ZERO
		_emit_movement_state()


func request_action() -> void:
	if not input_enabled:
		return
	action_requested.emit()


func reset_player(new_spawn_position: Variant = null) -> void:
	if new_spawn_position is Vector2:
		spawn_position = new_spawn_position
	global_position = spawn_position
	velocity = Vector2.ZERO
	last_move_direction = Vector2.DOWN
	input_enabled = true
	_was_moving = false
	reset_completed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("action"):
		request_action()


func _read_move_input() -> Vector2:
	if not input_enabled:
		return Vector2.ZERO
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")


func _update_last_direction(input_direction: Vector2) -> void:
	if input_direction.length_squared() > 0.0:
		last_move_direction = input_direction.normalized()
		if face_movement_direction:
			rotation = last_move_direction.angle()


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
