extends Node

signal run_started(level_id: StringName)
signal phase_changed(phase: GameRules.Phase)
signal operand_collected(value: int, slot: int)
signal operands_cleared
signal equation_submitted(correct: bool)
signal equation_changed(snapshot: Dictionary)
signal shield_changed(remaining: int)
signal tide_started
signal tide_finished
signal level_completed(level_id: StringName)
signal restart_requested

# Reserved by the repository QA contract for later levels.
signal player_died
signal health_changed(current: int, maximum: int)
signal score_changed(value: int)
signal game_over(won: bool, reason: StringName)

