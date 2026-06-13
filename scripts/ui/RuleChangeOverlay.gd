extends Control

var _visible_for_current_tide: bool = false
var _fade_tween: Tween


func _ready() -> void:
	hide()

	GameEvents.tide_started.connect(_on_tide_started)

	GameEvents.tide_finished.connect(_on_tide_finished)


func _unhandled_input(event: InputEvent) -> void:
	if not _visible_for_current_tide:
		return
	if event.is_action_pressed(&"action"):
		_hide_overlay()
		get_viewport().set_input_as_handled()


func _on_tide_started() -> void:
	_visible_for_current_tide = true
	modulate = Color.TRANSPARENT
	show()
	_fade_tween = create_tween()
	_fade_tween.tween_property(self, "modulate", Color.WHITE, 0.12)


func _on_tide_finished() -> void:
	_hide_overlay()


func _hide_overlay() -> void:
	_visible_for_current_tide = false
	if _fade_tween != null and _fade_tween.is_valid():
		_fade_tween.kill()
	modulate = Color.WHITE
	hide()
