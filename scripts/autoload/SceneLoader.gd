extends Node

var _restart_pending: bool = false


func _ready() -> void:
	if not GameEvents.restart_requested.is_connected(_on_restart_requested):
		GameEvents.restart_requested.connect(_on_restart_requested)
	if not GameEvents.run_started.is_connected(_on_run_started):
		GameEvents.run_started.connect(_on_run_started)


func restart_level_01() -> void:
	if _restart_pending:
		return

	_restart_pending = true
	GameState.input_enabled = false
	call_deferred("_reload_level_01")


func _reload_level_01() -> void:
	GameState.reset_level_01()
	var error: Error = get_tree().reload_current_scene()
	if error != OK:
		_restart_pending = false
		push_error("Unable to reload Level 1: %s" % error_string(error))


func _on_restart_requested() -> void:
	restart_level_01()


func _on_run_started(_level_id: StringName) -> void:
	_restart_pending = false
