extends Node
class_name PolinaActionCooldown

signal action_ready
signal action_started
signal action_rejected(reason: StringName)
signal cooldown_changed(seconds_left: float, duration: float)
signal reset_completed

@export var cooldown_seconds: float = 0.35
@export var buffer_seconds: float = 0.12
@export var start_ready: bool = true

var input_enabled: bool = true
var _cooldown_left: float = 0.0
var _buffer_left: float = 0.0


func _ready() -> void:
	reset_action()


func _process(delta: float) -> void:
	if _cooldown_left > 0.0:
		_cooldown_left = maxf(0.0, _cooldown_left - delta)
		cooldown_changed.emit(_cooldown_left, cooldown_seconds)
		if _cooldown_left == 0.0:
			action_ready.emit()

	if _buffer_left > 0.0:
		_buffer_left = maxf(0.0, _buffer_left - delta)
		if _buffer_left > 0.0 and can_start_action():
			_buffer_left = 0.0
			start_action()


func request_action() -> bool:
	if not input_enabled:
		action_rejected.emit(&"input_disabled")
		return false

	if can_start_action():
		return start_action()

	if buffer_seconds > 0.0:
		_buffer_left = buffer_seconds
	action_rejected.emit(&"cooldown")
	return false


func can_start_action() -> bool:
	return input_enabled and _cooldown_left <= 0.0


func start_action() -> bool:
	if not can_start_action():
		return false

	_cooldown_left = cooldown_seconds
	action_started.emit()
	cooldown_changed.emit(_cooldown_left, cooldown_seconds)
	return true


func set_input_enabled(enabled: bool) -> void:
	input_enabled = enabled
	if not input_enabled:
		_buffer_left = 0.0


func reset_action() -> void:
	_cooldown_left = 0.0 if start_ready else cooldown_seconds
	_buffer_left = 0.0
	input_enabled = true
	cooldown_changed.emit(_cooldown_left, cooldown_seconds)
	if _cooldown_left == 0.0:
		action_ready.emit()
	reset_completed.emit()
