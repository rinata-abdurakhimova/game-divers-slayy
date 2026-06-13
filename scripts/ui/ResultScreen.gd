extends Control

const ScoreServiceScript = preload("res://scripts/gameplay/ScoreService.gd")

@onready var title_label: Label = %TitleLabel
@onready var summary_label: Label = %SummaryLabel
@onready var restart_button: Button = %RestartButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	restart_button.pressed.connect(_on_restart_pressed)
	GameEvents.run_started.connect(hide)
	GameEvents.game_over.connect(_on_game_over)


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed(&"restart"):
		_on_restart_pressed()
		get_viewport().set_input_as_handled()


func _on_game_over(won: bool, reason: StringName, score_cents: int) -> void:
	title_label.text = "BOSS 67 DEFEATED" if won else "THE NUMBERS WON"
	summary_label.text = "EXACT SCORE: 67\nTHE SHORE IS FREE" if won else \
		"SCORE: %s\n%s" % [ScoreServiceScript.format_score(score_cents), _reason_text(reason)]
	restart_button.text = "PLAY AGAIN"
	show()
	restart_button.grab_focus()


func _on_restart_pressed() -> void:
	get_tree().paused = false
	GameEvents.restart_requested.emit()


func _reason_text(reason: StringName) -> String:
	if reason == &"score_zero":
		return "A SCORE OF 0 ENDS THE RUN"
	return str(reason).replace("_", " ").to_upper()
