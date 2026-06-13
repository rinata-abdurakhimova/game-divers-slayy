extends SceneTree

const ScoreServiceScript = preload("res://scripts/gameplay/ScoreService.gd")


func _initialize() -> void:
	assert(ScoreServiceScript.start_score_cents() == 100)
	assert(ScoreServiceScript.target_score_cents() == 6700)
	assert(ScoreServiceScript.failure_score_cents() == 0)

	assert(ScoreServiceScript.apply_score_operation(100, &"add", 600) == 700)
	assert(ScoreServiceScript.apply_score_operation(700, &"subtract", 1000) == -300)
	assert(ScoreServiceScript.apply_score_operation(333, &"multiply", 50) == 167)
	assert(ScoreServiceScript.apply_score_operation(333, &"multiply", 80) == 266)
	assert(ScoreServiceScript.apply_score_operation(333, &"multiply", 115) == 383)
	assert(ScoreServiceScript.apply_score_operation(-333, &"multiply", 115) == -383)
	assert(ScoreServiceScript.apply_score_operation(1234, &"unknown", 999) == 1234)

	assert(ScoreServiceScript.is_victory_score(6700))
	assert(not ScoreServiceScript.is_victory_score(6701))
	assert(not ScoreServiceScript.is_victory_score(6699))

	assert(ScoreServiceScript.is_failure_score(0))
	assert(not ScoreServiceScript.is_failure_score(-100))
	assert(ScoreServiceScript.can_continue(-100))
	assert(not ScoreServiceScript.can_continue(0))
	assert(not ScoreServiceScript.can_continue(6700))

	assert(ScoreServiceScript.format_score(6700) == "67")
	assert(ScoreServiceScript.format_score(6701) == "67.01")
	assert(ScoreServiceScript.format_score(6690) == "66.9")
	assert(ScoreServiceScript.format_score(-125) == "-1.25")

	var snapshot: Dictionary = ScoreServiceScript.make_snapshot(6700)
	assert(snapshot["score_cents"] == 6700)
	assert(snapshot["display"] == "67")
	assert(snapshot["is_victory"])
	assert(not snapshot["is_failure"])

	quit()
