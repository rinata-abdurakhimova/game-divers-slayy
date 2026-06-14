class_name Player
extends CharacterBody2D

signal movement_started
signal movement_stopped
signal reset_completed

@export_group("Platformer Movement")
@export var move_speed: float = GameRules.PLAYER_SPEED
@export var ground_acceleration: float = 2400.0
@export var air_acceleration: float = 1500.0
@export var ground_friction: float = 3200.0
@export var air_friction: float = 900.0
@export var gravity: float = 1450.0
@export var max_fall_speed: float = 900.0
@export var jump_velocity: float = -475.0
@export_range(0.05, 1.0, 0.01) var short_hop_multiplier: float = 0.45
@export_range(0.0, 0.3, 0.01) var coyote_time_seconds: float = 0.1
@export_range(0.0, 0.3, 0.01) var jump_buffer_seconds: float = 0.12

@export_group("Water Feel")
@export var water_friction_multiplier: float = 0.35    # slippery sliding in water
@export var water_acceleration_multiplier: float = 0.6

@export_group("Input")
@export var move_left_action: StringName = &"move_left"
@export var move_right_action: StringName = &"move_right"
@export var jump_action: StringName = &"jump"
@export var fallback_jump_action: StringName = &"action"
@export var respect_game_state_input: bool = true

@export_group("Visuals")
@export var land_visual_path: NodePath = ^"LandVisual"
@export var water_visual_path: NodePath = ^"WaterVisual"

var input_enabled: bool = true
var spawn_position: Vector2 = Vector2.ZERO
var current_phase: GameRules.Phase = GameRules.Phase.LAND

# Complication state
var _controls_reversed: bool = false
var _gravity_inverted: bool = false
var _has_double_jump: bool = false
var _double_jump_used: bool = false

var _land_visual: CanvasItem = null
var _water_visual: CanvasItem = null
var _was_moving: bool = false
var _coyote_timer: float = 0.0
var _jump_buffer_timer: float = 0.0


func _ready() -> void:
	spawn_position = global_position
	_land_visual = get_node_or_null(land_visual_path) as CanvasItem
	_water_visual = get_node_or_null(water_visual_path) as CanvasItem
	_connect_game_events()
	_apply_phase_visuals(current_phase)


func _physics_process(delta: float) -> void:
	if not _can_accept_input():
		_stop_for_disabled_input()
		return

	_update_jump_timers(delta)
	_update_horizontal_velocity(_read_horizontal_input(), delta)
	_apply_gravity(delta)
	_try_buffered_jump()
	_apply_short_hop()
	move_and_slide()
	_emit_movement_state()


# ── Public API ────────────────────────────────────────────────────────────────

func set_input_enabled(enabled: bool) -> void:
	input_enabled = enabled
	if not input_enabled:
		_stop_for_disabled_input()


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
	_coyote_timer = 0.0
	_jump_buffer_timer = 0.0
	_controls_reversed = false
	_gravity_inverted = false
	_has_double_jump = false
	_double_jump_used = false
	_apply_phase_visuals(current_phase)
	reset_completed.emit()


func grant_double_jump() -> void:
	_has_double_jump = true
	_double_jump_used = false


# ── Input ─────────────────────────────────────────────────────────────────────

func _read_horizontal_input() -> float:
	var raw: float = _get_action_strength(move_right_action) - _get_action_strength(move_left_action)
	return -raw if _controls_reversed else raw


func _can_accept_input() -> bool:
	if not input_enabled:
		return false
	if not respect_game_state_input:
		return true

	var game_state: Node = get_node_or_null(^"/root/GameState")
	if game_state == null:
		return true

	var gs_input: Variant = game_state.get("input_enabled")
	if gs_input is bool:
		return gs_input
	return true


func _update_jump_timers(delta: float) -> void:
	var on_ground: bool = _is_on_ground()
	if on_ground:
		_coyote_timer = coyote_time_seconds
		_double_jump_used = false   # reset double-jump on land
	else:
		_coyote_timer = maxf(_coyote_timer - delta, 0.0)

	var jump_pressed: bool = _controls_reversed and _is_down_just_pressed()
	jump_pressed = jump_pressed or (not _controls_reversed and _is_jump_just_pressed())

	if jump_pressed:
		_jump_buffer_timer = jump_buffer_seconds
	else:
		_jump_buffer_timer = maxf(_jump_buffer_timer - delta, 0.0)


func _update_horizontal_velocity(horizontal_input: float, delta: float) -> void:
	var in_water: bool = current_phase == GameRules.Phase.WATER
	var accel_mult: float = water_acceleration_multiplier if in_water else 1.0
	var friction_mult: float = water_friction_multiplier if in_water else 1.0

	var target_x: float = horizontal_input * move_speed
	var has_input: bool = not is_zero_approx(horizontal_input)
	var rate: float

	if has_input:
		rate = (ground_acceleration if _is_on_ground() else air_acceleration) * accel_mult
	else:
		rate = (ground_friction if _is_on_ground() else air_friction) * friction_mult

	velocity.x = move_toward(velocity.x, target_x, rate * delta)


func _apply_gravity(delta: float) -> void:
	var effective_gravity: float = -gravity if _gravity_inverted else gravity
	var max_speed: float = max_fall_speed

	if _gravity_inverted:
		# Inverted: player falls UP. Clamp to negative (upward) direction.
		if _is_on_ground() and velocity.y < 0.0:
			velocity.y = 0.0
			return
		velocity.y = maxf(velocity.y + effective_gravity * delta, -max_speed)
	else:
		if _is_on_ground() and velocity.y > 0.0:
			velocity.y = 0.0
			return
		velocity.y = minf(velocity.y + effective_gravity * delta, max_speed)


func _try_buffered_jump() -> void:
	if _jump_buffer_timer <= 0.0:
		return

	if _coyote_timer > 0.0:
		# Normal jump / inverted ceiling jump.
		velocity.y = -jump_velocity if _gravity_inverted else jump_velocity
		_jump_buffer_timer = 0.0
		_coyote_timer = 0.0
	elif _has_double_jump and not _double_jump_used:
		# Double-jump power-up mid-air.
		velocity.y = -jump_velocity if _gravity_inverted else jump_velocity
		_double_jump_used = true
		_jump_buffer_timer = 0.0


func _apply_short_hop() -> void:
	var released: bool = _is_jump_just_released()
	if not released:
		return
	if _gravity_inverted and velocity.y > 0.0:
		velocity.y *= short_hop_multiplier
	elif not _gravity_inverted and velocity.y < 0.0:
		velocity.y *= short_hop_multiplier


func _is_on_ground() -> bool:
	# In inverted gravity mode, "ground" is the ceiling.
	return is_on_ceiling() if _gravity_inverted else is_on_floor()


# ── Complication helpers ──────────────────────────────────────────────────────

func _apply_complication(complication: GameRules.WaterComplication) -> void:
	_controls_reversed = (complication == GameRules.WaterComplication.REVERSED_CONTROLS)
	_gravity_inverted = false
	up_direction = Vector2.UP


func _clear_complication() -> void:
	_controls_reversed = false
	_gravity_inverted  = false
	up_direction = Vector2.UP


# ── Internal helpers ──────────────────────────────────────────────────────────

func _stop_for_disabled_input() -> void:
	velocity = Vector2.ZERO
	_coyote_timer = 0.0
	_jump_buffer_timer = 0.0
	_emit_movement_state()


func _get_action_strength(action: StringName) -> float:
	if not InputMap.has_action(action):
		return 0.0
	return Input.get_action_strength(action)


func _is_jump_just_pressed() -> bool:
	if InputMap.has_action(jump_action):
		return Input.is_action_just_pressed(jump_action)
	if InputMap.has_action(fallback_jump_action):
		return Input.is_action_just_pressed(fallback_jump_action)
	return false


func _is_jump_just_released() -> bool:
	if InputMap.has_action(jump_action):
		return Input.is_action_just_released(jump_action)
	if InputMap.has_action(fallback_jump_action):
		return Input.is_action_just_released(fallback_jump_action)
	return false


func _is_down_just_pressed() -> bool:
	# Used only for reversed controls where down acts as jump.
	return Input.is_action_just_pressed(&"ui_down")


func _emit_movement_state() -> void:
	var is_moving: bool = velocity.length_squared() > 1.0
	if is_moving == _was_moving:
		return
	_was_moving = is_moving
	if is_moving:
		movement_started.emit()
	else:
		movement_stopped.emit()


# ── GameEvents wiring ─────────────────────────────────────────────────────────

func _connect_game_events() -> void:
	var ge: Node = get_node_or_null(^"/root/GameEvents")
	if ge == null:
		return
	_connect_optional_signal(ge, &"water_started",  Callable(self, "_on_water_started"))
	_connect_optional_signal(ge, &"water_finished", Callable(self, "_on_water_finished"))
	_connect_optional_signal(ge, &"powerup_started", Callable(self, "_on_powerup_started"))
	_connect_optional_signal(ge, &"powerup_finished", Callable(self, "_on_powerup_finished"))


func _connect_optional_signal(source: Node, signal_name: StringName, target: Callable) -> void:
	if not source.has_signal(signal_name):
		return
	if not source.is_connected(signal_name, target):
		source.connect(signal_name, target)


func _apply_phase_visuals(phase: GameRules.Phase) -> void:
	var in_water: bool = phase == GameRules.Phase.WATER or phase == GameRules.Phase.COMPLETE
	if _land_visual != null:
		_land_visual.visible = not in_water
	if _water_visual != null:
		_water_visual.visible = in_water


func _on_water_started(
	_variant: Variant = null,
	complication: Variant = null,
	_seconds: float = 0.0
) -> void:
	current_phase = GameRules.Phase.WATER
	_apply_phase_visuals(current_phase)
	if complication is GameRules.WaterComplication:
		_apply_complication(complication)


func _on_water_finished() -> void:
	current_phase = GameRules.Phase.LAND
	_apply_phase_visuals(current_phase)
	_clear_complication()


func _on_powerup_started(kind: StringName, _seconds: float) -> void:
	if kind == GameRules.POWERUP_DOUBLE_JUMP:
		grant_double_jump()


func _on_powerup_finished(kind: StringName) -> void:
	if kind == GameRules.POWERUP_DOUBLE_JUMP:
		_has_double_jump = false
		_double_jump_used = false
