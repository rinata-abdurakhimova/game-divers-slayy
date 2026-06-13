extends SceneTree


func _initialize() -> void:
	var game_state: Node = root.get_node(^"GameState")

	game_state.call(&"reset_boss_67_run")
	assert(game_state.get("score_cents") == GameRules.BOSS_67_START_SCORE_CENTS)
	assert(game_state.get("phase") == GameRules.RunPhase.SAFE_START)
	assert(game_state.get("water_variant") == GameRules.WaterVariant.NONE)
	assert((game_state.get("active_powerups") as Dictionary).is_empty())
	assert(game_state.get("input_enabled"))
	assert(not game_state.get("outcome_locked"))

	assert(game_state.call(
		&"apply_score_operation",
		GameRules.SCORE_OPERATION_ADD,
		6600,
		&"test_pickup"
	))
	assert(game_state.get("score_cents") == GameRules.BOSS_67_TARGET_SCORE_CENTS)
	assert(game_state.get("phase") == GameRules.RunPhase.COMPLETE)
	assert(not game_state.get("input_enabled"))
	assert(game_state.get("outcome_locked"))

	game_state.call(&"reset_boss_67_run")
	assert(game_state.call(
		&"apply_score_operation",
		GameRules.SCORE_OPERATION_MULTIPLY,
		0,
		&"test_projectile"
	))
	assert(game_state.get("score_cents") == GameRules.BOSS_67_FAILURE_SCORE_CENTS)
	assert(game_state.get("phase") == GameRules.RunPhase.FAILED)

	game_state.call(&"reset_boss_67_run")
	game_state.call(
		&"begin_water_event",
		GameRules.WaterVariant.WATER_A,
		GameRules.WaterComplication.REVERSED_CONTROLS
	)
	assert(game_state.get("phase") == GameRules.RunPhase.WATER)
	assert(game_state.get("water_seconds_left") > 0.0)
	game_state.call(&"activate_powerup", GameRules.POWERUP_SLOW, 5.0)
	assert((game_state.get("active_powerups") as Dictionary).has(GameRules.POWERUP_SLOW))

	game_state.call(&"reset_boss_67_run")
	assert(game_state.get("water_variant") == GameRules.WaterVariant.NONE)
	assert((game_state.get("active_powerups") as Dictionary).is_empty())
	quit()
