extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	await _load_main()

	var game_state: Node = root.get_node(^"GameState")
	var game_events: Node = root.get_node(^"GameEvents")
	var intro: Control = current_scene.get_node(^"UI/CutsceneIntro") as Control
	var level_container: Node = current_scene.get_node(^"LevelContainer")
	var hud: Control = current_scene.get_node(^"UI/HUD") as Control

	assert(intro.visible)
	assert(level_container.get_child_count() == 0)
	assert(not hud.visible)

	intro.call(&"finish_intro")
	await process_frame
	assert(not intro.visible)
	assert(level_container.get_child_count() == 1)
	assert(hud.visible)
	assert(game_state.get("score_cents") == GameRules.BOSS_67_START_SCORE_CENTS)

	game_state.call(
		&"begin_water_event",
		GameRules.WaterVariant.WATER_A,
		GameRules.WaterComplication.NONE
	)
	await process_frame
	var water_overlay: Control = current_scene.get_node(^"UI/WaterRuleOverlay") as Control
	assert(water_overlay.visible)

	game_state.call(
		&"apply_score_operation",
		GameRules.SCORE_OPERATION_ADD,
		6600,
		&"test_pickup"
	)
	await process_frame
	var result_screen: Control = current_scene.get_node(^"UI/ResultScreen") as Control
	assert(result_screen.visible)
	assert(game_state.get("phase") == GameRules.RunPhase.COMPLETE)

	game_events.emit_signal(&"restart_requested")
	await scene_changed
	await process_frame
	assert(game_state.get("score_cents") == GameRules.BOSS_67_START_SCORE_CENTS)
	assert(game_state.get("water_variant") == GameRules.WaterVariant.NONE)
	assert((game_state.get("active_powerups") as Dictionary).is_empty())
	assert(game_state.get("input_enabled"))
	assert(not game_state.get("outcome_locked"))

	intro = current_scene.get_node(^"UI/CutsceneIntro") as Control
	intro.call(&"finish_intro")
	await process_frame
	game_state.call(
		&"apply_score_operation",
		GameRules.SCORE_OPERATION_MULTIPLY,
		0,
		&"test_projectile"
	)
	await process_frame
	result_screen = current_scene.get_node(^"UI/ResultScreen") as Control
	assert(result_screen.visible)
	assert(game_state.get("phase") == GameRules.RunPhase.FAILED)

	game_events.emit_signal(&"restart_requested")
	await scene_changed
	await process_frame
	assert(game_state.get("score_cents") == GameRules.BOSS_67_START_SCORE_CENTS)
	assert(current_scene.get_node(^"UI/CutsceneIntro").visible)

	if current_scene != null:
		current_scene.queue_free()
		await process_frame
	quit()


func _load_main() -> void:
	var change_error: Error = change_scene_to_file("res://scenes/main/Main.tscn")
	assert(change_error == OK)
	await scene_changed
	await process_frame
