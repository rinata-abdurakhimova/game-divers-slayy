extends Control

signal intro_finished

@onready var start_button: Button = %StartButton

var _finished: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	start_button.pressed.connect(finish_intro)
	start_button.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed(&"action"):
		finish_intro()
		get_viewport().set_input_as_handled()


func finish_intro() -> void:
	if _finished:
		return
	_finished = true
	hide()
	intro_finished.emit()
	GameEvents.cutscene_finished.emit()
