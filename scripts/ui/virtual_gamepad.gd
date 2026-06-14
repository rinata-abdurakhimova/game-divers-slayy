extends Control

@export var joystick_dead_zone: float = 0.15
@export var joystick_base_radius: float = 60.0
@export var joystick_thumb_radius: float = 25.0
@export var jump_btn_radius: float = 50.0
@export var pause_btn_radius: float = 24.0

var _cached_vp_size: Vector2
var _joystick_base_pos: Vector2
var _jump_btn_center: Vector2
var _pause_btn_center: Vector2

var _joystick_touch_id: int = -1
var _joystick_value: Vector2 = Vector2.ZERO
var _jump_touch_id: int = -1
var _pause_touch_id: int = -1


func _ready() -> void:
	if not DisplayServer.is_touchscreen_available():
		hide()
		return
	mouse_filter = MOUSE_FILTER_IGNORE
	_recalculate_positions()


func _input(event: InputEvent) -> void:
	if not visible:
		return

	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			_try_claim_touch(touch)
		else:
			_release_touch(touch.index)

	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		if drag.index == _joystick_touch_id:
			_update_joystick(drag.position)
		elif drag.index == _jump_touch_id:
			if drag.position.distance_to(_jump_btn_center) > jump_btn_radius * 2.0:
				_jump_touch_id = -1
				Input.action_release("jump")


func _try_claim_touch(touch: InputEventScreenTouch) -> void:
	var vp_size: Vector2 = get_viewport_rect().size

	if touch.position.distance_to(_pause_btn_center) < pause_btn_radius * 1.5:
		_pause_touch_id = touch.index
		_send_action(&"pause", true)

	elif get_tree().paused:
		return

	elif touch.position.x < vp_size.x * 0.35 and touch.position.y > vp_size.y * 0.35:
		_joystick_touch_id = touch.index
		_update_joystick(touch.position)

	elif touch.position.distance_to(_jump_btn_center) < jump_btn_radius * 1.5:
		_jump_touch_id = touch.index
		Input.action_press("jump")


func _release_touch(touch_index: int) -> void:
	if touch_index == _joystick_touch_id:
		_joystick_touch_id = -1
		_joystick_value = Vector2.ZERO
		Input.action_release("move_right")
		Input.action_release("move_left")
		queue_redraw()
	elif touch_index == _jump_touch_id:
		_jump_touch_id = -1
		Input.action_release("jump")
	elif touch_index == _pause_touch_id:
		_pause_touch_id = -1


func _update_joystick(touch_pos: Vector2) -> void:
	var delta: Vector2 = touch_pos - _joystick_base_pos
	var distance: float = delta.length()
	var max_dist: float = joystick_base_radius

	if distance > max_dist:
		delta = delta / distance * max_dist

	var value: Vector2 = delta / max_dist

	if absf(value.x) < joystick_dead_zone:
		value.x = 0.0
	else:
		value.x = (value.x - signf(value.x) * joystick_dead_zone) / (1.0 - joystick_dead_zone)

	if value.x > 0.0:
		Input.action_press("move_right", value.x)
		Input.action_release("move_left")
	elif value.x < 0.0:
		Input.action_press("move_left", -value.x)
		Input.action_release("move_right")
	else:
		Input.action_release("move_right")
		Input.action_release("move_left")

	_joystick_value = value
	queue_redraw()


func _send_action(action_name: StringName, pressed: bool) -> void:
	var event := InputEventAction.new()
	event.action = action_name
	event.pressed = pressed
	Input.parse_input_event(event)


func _recalculate_positions() -> void:
	var vp_size: Vector2 = get_viewport_rect().size
	if vp_size == _cached_vp_size:
		return
	_cached_vp_size = vp_size

	var m: float = 45.0
	_joystick_base_pos = Vector2(joystick_base_radius + m, vp_size.y - joystick_base_radius - m)
	_jump_btn_center = Vector2(vp_size.x - jump_btn_radius - m, vp_size.y - jump_btn_radius - m)
	_pause_btn_center = Vector2(vp_size.x - pause_btn_radius - m, pause_btn_radius + m)


func _draw() -> void:
	if not visible:
		return
	_recalculate_positions()

	var joystick_thumb_offset: Vector2 = _joystick_value * joystick_base_radius

	draw_circle(_joystick_base_pos, joystick_base_radius, Color(1, 1, 1, 0.15))
	draw_circle(_joystick_base_pos, joystick_base_radius, Color(1, 1, 1, 0.3), false, 2.0)
	draw_circle(_joystick_base_pos + joystick_thumb_offset, joystick_thumb_radius, Color(1, 1, 1, 0.4))
	draw_circle(_joystick_base_pos + joystick_thumb_offset, joystick_thumb_radius, Color(1, 1, 1, 0.7), false, 2.0)

	draw_circle(_jump_btn_center, jump_btn_radius, Color(0.3, 0.8, 0.4, 0.5))
	draw_circle(_jump_btn_center, jump_btn_radius, Color(0.3, 0.8, 0.4, 0.8), false, 2.0)
	_draw_centered_text("JUMP", _jump_btn_center, 18)

	draw_circle(_pause_btn_center, pause_btn_radius, Color(0.8, 0.6, 0.2, 0.5))
	draw_circle(_pause_btn_center, pause_btn_radius, Color(0.8, 0.6, 0.2, 0.8), false, 2.0)
	var pause_label: String = "II"
	_draw_centered_text(pause_label, _pause_btn_center, 12)


func _draw_centered_text(text: String, center: Vector2, font_size: int) -> void:
	var font: Font = ThemeDB.fallback_font
	var text_size: Vector2 = font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
	var pos: Vector2 = center - text_size * 0.5
	pos.y += text_size.y * 0.35
	draw_string(font, pos, text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, Color(1, 1, 1, 0.9))
