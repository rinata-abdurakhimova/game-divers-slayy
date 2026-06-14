extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	await _load_main()

	var game_state: Node = root.get_node(^"GameState")
	var game_events: Node = root.get_node(^"GameEvents")
	_assert_intro_state(game_state)
	await _start_gameplay()
	_assert_playing_state(game_state)

	# Restart from ordinary land gameplay.
	game_events.emit_signal(&"restart_requested")
	await scene_changed
	await process_frame
	_assert_intro_state(game_state)
	await _start_gameplay()

	# Restart while the water timer is active.
	game_state.call(
		&"begin_water_event",
		GameRules.WaterVariant.WATER_A,
		GameRules.WaterComplication.NONE
	)
	await process_frame
	assert(game_state.get("phase") == GameRules.RunPhase.WATER)
	assert((current_scene.get_node(^"UI/WaterRuleOverlay") as Control).visible)
	var hud: Control = current_scene.get_node(^"UI/HUD") as Control
	assert(hud.get_node(^"TopMargin/TopRow/LeftColumn/WaterPanel").visible)
	var rule_label: Label = hud.get_node(
		^"TopMargin/TopRow/LeftColumn/WaterPanel/WaterColumn/WaterRuleLabel"
	) as Label
	assert(not rule_label.text.is_empty())
	game_events.emit_signal(&"restart_requested")
	await scene_changed
	await process_frame
	_assert_intro_state(game_state)
	await _start_gameplay()

	# Restart after failure at exact zero.
	game_state.call(
		&"apply_score_operation",
		GameRules.SCORE_OPERATION_MULTIPLY,
		0,
		&"test_projectile"
	)
	await process_frame
	assert(game_state.get("phase") == GameRules.RunPhase.FAILED)
	assert((current_scene.get_node(^"UI/ResultScreen") as Control).visible)
	game_events.emit_signal(&"restart_requested")
	await scene_changed
	await process_frame
	_assert_intro_state(game_state)
	await _start_gameplay()

	# Restart after victory at exact 67.
	game_state.call(
		&"apply_score_operation",
		GameRules.SCORE_OPERATION_ADD,
		6600,
		&"test_pickup"
	)
	await process_frame
	assert(game_state.get("phase") == GameRules.RunPhase.COMPLETE)
	assert((current_scene.get_node(^"UI/ResultScreen") as Control).visible)
	game_events.emit_signal(&"restart_requested")
	await scene_changed
	await process_frame
	_assert_intro_state(game_state)

	if current_scene != null:
		current_scene.queue_free()
		await process_frame
	quit()


func _load_main() -> void:
	var change_error: Error = change_scene_to_file("res://scenes/main/Main.tscn")
	assert(change_error == OK)
	await scene_changed
	await process_frame


func _start_gameplay() -> void:
	var game_state: Node = root.get_node(^"GameState")
	var intro: Control = current_scene.get_node(^"UI/CutsceneIntro") as Control
	intro.call(&"finish_intro")
	await process_frame
	assert(not intro.visible)
	assert(not (current_scene.get_node(^"UI/ResultScreen") as Control).visible)
	assert(current_scene.get_node(^"LevelContainer").get_child_count() == 1)
	var level: Node = current_scene.get_node(^"LevelContainer").get_child(0)
	assert(level.name == &"Boss67Level")
	assert((level as Node2D).visible)
	assert(level.process_mode == Node.PROCESS_MODE_INHERIT)
	assert(level.get_node(^"LevelController").get_script() != null)
	var player: CharacterBody2D = level.get_node(^"Actors/Player") as CharacterBody2D
	assert(player.global_position.distance_to(Vector2(60, 555)) < 1.0)
	assert(player.velocity.length_squared() < 1.0)
	assert(level.get_node(^"Pickups").get_child_count() == 0)
	assert(level.get_node(^"Projectiles").get_child_count() == 0)
	assert((current_scene.get_node(^"UI/HUD") as Control).visible)
	assert(game_state.get("score_cents") == GameRules.BOSS_67_START_SCORE_CENTS)
	assert(game_state.get("phase") == GameRules.RunPhase.SAFE_START)
	assert(not game_state.get("outcome_locked"))


func _assert_intro_state(game_state: Node) -> void:
	assert((current_scene.get_node(^"UI/CutsceneIntro") as Control).visible)
	assert(current_scene.get_node(^"LevelContainer").get_child_count() == 1)
	var level: Node2D = current_scene.get_node(^"LevelContainer/Boss67Level") as Node2D
	assert(not level.visible)
	assert(level.process_mode == Node.PROCESS_MODE_DISABLED)
	assert(not (current_scene.get_node(^"UI/HUD") as Control).visible)
	assert(not (current_scene.get_node(^"UI/TutorialOverlay") as Control).visible)
	assert(not (current_scene.get_node(^"UI/WaterRuleOverlay") as Control).visible)
	assert(not (current_scene.get_node(^"UI/ResultScreen") as Control).visible)
	assert(game_state.get("score_cents") == GameRules.BOSS_67_START_SCORE_CENTS)
	assert(game_state.get("distance_blocks") == 0)
	assert(game_state.get("boss_phase") == GameRules.BossPhase.HIDDEN)
	assert(game_state.get("water_variant") == GameRules.WaterVariant.NONE)
	assert((game_state.get("active_powerups") as Dictionary).is_empty())
	assert(game_state.get("input_enabled"))
	assert(not game_state.get("outcome_locked"))


func _assert_playing_state(game_state: Node) -> void:
	assert(game_state.get("score_cents") == GameRules.BOSS_67_START_SCORE_CENTS)
	assert(game_state.get("phase") == GameRules.RunPhase.SAFE_START)
	assert(game_state.get("input_enabled"))
