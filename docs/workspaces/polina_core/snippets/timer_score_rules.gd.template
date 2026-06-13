extends Node
class_name PolinaTimerScoreRules

signal run_started
signal score_changed(value: int)
signal timer_changed(seconds_left: float)
signal level_completed
signal run_failed(reason: StringName)
signal game_over(won: bool, reason: StringName)
signal reset_completed

@export var time_limit_seconds: float = 60.0
@export var win_score: int = 5
@export var fail_on_timeout: bool = true
@export var auto_start: bool = false

var score: int = 0
var seconds_left: float = 0.0
var run_active: bool = false
var outcome_locked: bool = false


func _ready() -> void:
	reset_rules()
	if auto_start:
		start_run()


func _process(delta: float) -> void:
	if not run_active:
		return
	if time_limit_seconds <= 0.0:
		return

	seconds_left = maxf(0.0, seconds_left - delta)
	timer_changed.emit(seconds_left)

	if seconds_left <= 0.0 and fail_on_timeout:
		fail_run(&"timeout")


func start_run() -> void:
	if run_active:
		return
	run_active = true
	outcome_locked = false
	run_started.emit()
	score_changed.emit(score)
	timer_changed.emit(seconds_left)


func add_score(amount: int) -> void:
	if not run_active or outcome_locked:
		return
	if amount == 0:
		return

	score = maxi(0, score + amount)
	score_changed.emit(score)

	if win_score > 0 and score >= win_score:
		complete_level()


func complete_level() -> void:
	if outcome_locked:
		return
	outcome_locked = true
	run_active = false
	level_completed.emit()
	game_over.emit(true, &"completed")


func fail_run(reason: StringName = &"failed") -> void:
	if outcome_locked:
		return
	outcome_locked = true
	run_active = false
	run_failed.emit(reason)
	game_over.emit(false, reason)


func reset_rules() -> void:
	score = 0
	seconds_left = maxf(0.0, time_limit_seconds)
	run_active = false
	outcome_locked = false
	score_changed.emit(score)
	timer_changed.emit(seconds_left)
	reset_completed.emit()
