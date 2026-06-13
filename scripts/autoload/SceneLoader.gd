extends Node

var _restart_pending: bool = false


func _ready() -> void:
	GameEvents.restart_requested.connect(_on_restart_requested)
	GameEvents.run_started.connect(_on_run_started)


func restart_current_run() -> void:
	if _restart_pending:
		return
	_restart_pending = true
	GameState.input_enabled = false
	call_deferred("_reload_current_run")


func _reload_current_run() -> void:
	GameState.reset_boss_67_run()
	var error: Error = get_tree().reload_current_scene()
	if error != OK:
		_restart_pending = false
		push_error("Unable to reload Boss 67 Level 1: %s" % error_string(error))


func _on_restart_requested() -> void:
	restart_current_run()


func _on_run_started() -> void:
	_restart_pending = false
