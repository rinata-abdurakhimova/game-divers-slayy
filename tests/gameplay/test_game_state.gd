extends SceneTree


func _initialize() -> void:
	var game_state: Node = root.get_node(^"GameState")

	game_state.call(&"reset_level_01")
	assert(game_state.get("phase") == GameRules.Phase.LAND)
	assert(game_state.get("operation") == GameRules.Operation.ADD)
	assert(game_state.get("shield_segments") == 2)
	assert((game_state.get("operands") as Array).is_empty())
	assert(game_state.get("input_enabled"))

	assert(game_state.call(&"try_collect_operand", 4))
	assert(not game_state.call(&"submit_equation"))
	assert((game_state.get("operands") as Array).is_empty())

	assert(game_state.call(&"try_collect_operand", 4))
	assert(game_state.call(&"try_collect_operand", 6))
	assert(not game_state.call(&"try_collect_operand", 2))
	assert(game_state.call(&"submit_equation"))
	assert(game_state.get("shield_segments") == 1)
	assert(game_state.get("phase") == GameRules.Phase.LAND)
	assert((game_state.get("operands") as Array).is_empty())

	game_state.call(&"begin_tide_transition")
	assert(game_state.get("phase") == GameRules.Phase.TRANSITION)
	assert(not game_state.get("input_enabled"))
	assert(not game_state.call(&"try_collect_operand", 14))

	game_state.call(&"enter_water_phase")
	assert(game_state.get("phase") == GameRules.Phase.WATER)
	assert(game_state.get("operation") == GameRules.Operation.SUBTRACT)
	assert(game_state.get("input_enabled"))

	assert(game_state.call(&"try_collect_operand", 4))
	assert(game_state.call(&"try_collect_operand", 14))
	assert(not game_state.call(&"submit_equation"))
	assert(game_state.get("phase") == GameRules.Phase.WATER)
	assert(game_state.get("shield_segments") == 1)
	assert((game_state.get("operands") as Array).is_empty())

	assert(game_state.call(&"try_collect_operand", 14))
	assert(game_state.call(&"try_collect_operand", 4))
	assert(game_state.call(&"submit_equation"))
	assert(game_state.get("phase") == GameRules.Phase.COMPLETE)
	assert(game_state.get("shield_segments") == 0)
	assert(not game_state.get("input_enabled"))

	game_state.call(&"reset_level_01")
	assert(game_state.get("phase") == GameRules.Phase.LAND)
	assert(game_state.get("shield_segments") == 2)
	assert((game_state.get("operands") as Array).is_empty())
	assert(game_state.get("input_enabled"))
	quit()
