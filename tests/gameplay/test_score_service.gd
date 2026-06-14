extends SceneTree

const ScoreServiceScript = preload("res://scripts/gameplay/ScoreService.gd")


func _initialize() -> void:
	assert(ScoreServiceScript.start_score_cents() == 100)
	assert(ScoreServiceScript.target_score_cents() == 6700)
	assert(ScoreServiceScript.failure_score_cents() == 0)

	assert(ScoreServiceScript.apply_score_operation(100, &"add", 600) == 700)
	assert(ScoreServiceScript.apply_score_operation(700, &"subtract", 1000) == -300)
	assert(ScoreServiceScript.apply_score_operation(100, &"add", 115) == 200)
	assert(ScoreServiceScript.apply_score_operation(100, &"subtract", 150) == -100)
	assert(ScoreServiceScript.apply_score_operation(333, &"multiply", 50) == 200)
	assert(ScoreServiceScript.apply_score_operation(333, &"multiply", 80) == 300)
	assert(ScoreServiceScript.apply_score_operation(333, &"multiply", 115) == 400)
	assert(ScoreServiceScript.apply_score_operation(-333, &"multiply", 115) == -400)
	assert(ScoreServiceScript.apply_score_operation(100, &"multiply", 50) == 100)
	assert(ScoreServiceScript.apply_score_operation(100, &"multiply", 0) == 0)
	assert(ScoreServiceScript.apply_score_operation(6400, &"multiply", 105) == 6700)
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
	assert(ScoreServiceScript.format_score(6701) == "67")
	assert(ScoreServiceScript.format_score(6690) == "67")
	assert(ScoreServiceScript.format_score(-125) == "-1")
	assert(ScoreServiceScript.format_operation_value(115) == "1.15")
	assert(ScoreServiceScript.operation_label(&"multiply", 50) == "*0.5")

	var snapshot: Dictionary = ScoreServiceScript.make_snapshot(6700)
	assert(snapshot["score_cents"] == 6700)
	assert(snapshot["display"] == "67")
	assert(snapshot["is_victory"])
	assert(not snapshot["is_failure"])

	quit()
