extends Control


func _ready() -> void:
	hide()

	if GameEvents.tide_started.is_connected(_on_tide_started):
		GameEvents.tide_started.disconnect(_on_tide_started)
	GameEvents.tide_started.connect(_on_tide_started)

	if GameEvents.tide_finished.is_connected(_on_tide_finished):
		GameEvents.tide_finished.disconnect(_on_tide_finished)
	GameEvents.tide_finished.connect(_on_tide_finished)


func _on_tide_started() -> void:
	show()


func _on_tide_finished() -> void:
	hide()
