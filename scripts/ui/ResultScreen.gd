extends Control

@onready var restart_button: Button = %RestartButton


func _ready() -> void:
	hide()
	restart_button.pressed.connect(_on_restart_pressed)
	GameEvents.level_completed.connect(_on_level_completed)


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed(&"restart"):
		_on_restart_pressed()
		get_viewport().set_input_as_handled()


func _on_level_completed(_level_id: StringName) -> void:
	show()
	restart_button.grab_focus()


func _on_restart_pressed() -> void:
	GameEvents.restart_requested.emit()

