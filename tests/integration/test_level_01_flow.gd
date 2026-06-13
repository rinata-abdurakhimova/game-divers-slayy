extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var change_error: Error = change_scene_to_file("res://scenes/main/Main.tscn")
	assert(change_error == OK)
	await scene_changed
	await process_frame

	var game_state: Node = root.get_node(^"GameState")
	var game_events: Node = root.get_node(^"GameEvents")
	assert(game_state.get("phase") == GameRules.Phase.LAND)

	assert(game_state.call(&"try_collect_operand", 4))
	assert(game_state.call(&"try_collect_operand", 6))
	assert(game_state.call(&"submit_equation"))
	assert(game_state.get("phase") == GameRules.Phase.TRANSITION)

	var overlay: Control = current_scene.get_node(^"UI/RuleChangeOverlay") as Control
	assert(overlay != null and overlay.visible)

	await create_timer(GameRules.TIDE_TRANSITION_SECONDS + 0.1).timeout
	assert(not overlay.visible)
	assert(game_state.get("phase") == GameRules.Phase.WATER)

	assert(game_state.call(&"try_collect_operand", 14))
	assert(game_state.call(&"try_collect_operand", 4))
	assert(game_state.call(&"submit_equation"))
	assert(game_state.get("phase") == GameRules.Phase.COMPLETE)

	var result_screen: Control = current_scene.get_node(^"UI/ResultScreen") as Control
	assert(result_screen != null and result_screen.visible)

	for restart_index: int in 2:
		game_events.emit_signal(&"restart_requested")
		await scene_changed
		await process_frame
		assert(game_state.get("phase") == GameRules.Phase.LAND)
		assert(game_state.get("shield_segments") == GameRules.LEVEL_01_STARTING_SHIELDS)
		assert((game_state.get("operands") as Array).is_empty())
		assert(game_state.get("input_enabled"))

	if current_scene != null:
		current_scene.queue_free()
		await process_frame
	quit()
