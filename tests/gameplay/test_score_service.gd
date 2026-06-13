extends SceneTree


func _initialize() -> void:
	assert(ScoreService.start_score_cents() == 100)
	assert(ScoreService.target_score_cents() == 6700)
	assert(ScoreService.failure_score_cents() == 0)

	assert(ScoreService.apply_score_operation(100, &"add", 600) == 700)
	assert(ScoreService.apply_score_operation(700, &"subtract", 1000) == -300)
	assert(ScoreService.apply_score_operation(333, &"multiply", 50) == 167)
	assert(ScoreService.apply_score_operation(333, &"multiply", 80) == 266)
	assert(ScoreService.apply_score_operation(333, &"multiply", 115) == 383)
	assert(ScoreService.apply_score_operation(-333, &"multiply", 115) == -383)
	assert(ScoreService.apply_score_operation(1234, &"unknown", 999) == 1234)

	assert(ScoreService.is_victory_score(6700))
	assert(not ScoreService.is_victory_score(6701))
	assert(not ScoreService.is_victory_score(6699))

	assert(ScoreService.is_failure_score(0))
	assert(not ScoreService.is_failure_score(-100))
	assert(ScoreService.can_continue(-100))
	assert(not ScoreService.can_continue(0))
	assert(not ScoreService.can_continue(6700))

	assert(ScoreService.format_score(6700) == "67")
	assert(ScoreService.format_score(6701) == "67.01")
	assert(ScoreService.format_score(6690) == "66.9")
	assert(ScoreService.format_score(-125) == "-1.25")

	var snapshot: Dictionary = ScoreService.make_snapshot(6700)
	assert(snapshot["score_cents"] == 6700)
	assert(snapshot["display"] == "67")
	assert(snapshot["is_victory"])
	assert(not snapshot["is_failure"])

	quit()
