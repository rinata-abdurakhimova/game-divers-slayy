extends Control

@onready var target_label: Label = %TargetLabel
@onready var equation_label: Label = %EquationLabel
@onready var rule_label: Label = %RuleLabel
@onready var hint_label: Label = %HintLabel
@onready var phase_stage: Control = %PhaseStage
@onready var phase_background: ColorRect = %PhaseBackground
@onready var phase_highlight: ColorRect = %PhaseHighlight
@onready var stage_label: Label = %StageLabel
@onready var shield_one: PanelContainer = %ShieldOne
@onready var shield_two: PanelContainer = %ShieldTwo
@onready var shield_one_label: Label = %ShieldOneLabel

var _feedback_tween: Tween


func _ready() -> void:
	GameEvents.equation_changed.connect(_on_equation_changed)
	GameEvents.phase_changed.connect(_on_phase_changed)
	GameEvents.shield_changed.connect(_on_shield_changed)
	GameEvents.equation_submitted.connect(_on_equation_submitted)

	_on_equation_changed(GameState.get_equation_snapshot())
	_on_phase_changed(GameState.phase)
	_on_shield_changed(GameState.shield_segments)


func _on_equation_changed(snapshot: Dictionary) -> void:
	var snapshot_target: int = int(snapshot.get("target", GameRules.LEVEL_01_TARGET))
	var snapshot_operation: GameRules.Operation = snapshot.get(
		"operation",
		GameRules.LAND_OPERATION
	)
	var snapshot_operands: Array = snapshot.get("operands", [])

	target_label.text = "TARGET %d" % snapshot_target
	equation_label.text = "%s %s %s = %d" % [
		_operand_text(snapshot_operands, 0),
		_operation_text(snapshot_operation),
		_operand_text(snapshot_operands, 1),
		snapshot_target,
	]


func _on_phase_changed(new_phase: GameRules.Phase) -> void:
	match new_phase:
		GameRules.Phase.LAND:
			phase_stage.show()
			_set_stage_colors(Color("#F3C6A5"), Color("#FFD9B8"))
			stage_label.text = "SAND PHASE"
			rule_label.text = "COMBINE"
			hint_label.text = "Reach exactly 67"
		GameRules.Phase.TRANSITION:
			phase_stage.show()
			_set_stage_colors(Color("#D98BC8"), Color("#FFDCF6"))
			stage_label.text = "TIDE RISING"
			rule_label.text = "CHANGING..."
			hint_label.text = "Water changes the score rule"
		GameRules.Phase.WATER:
			phase_stage.show()
			_set_stage_colors(Color("#E78DD2"), Color("#FFDCF6"))
			stage_label.text = "PINK WATER PHASE"
			rule_label.text = "SPLIT"
			hint_label.text = "Read the active water rule"
		GameRules.Phase.COMPLETE:
			phase_stage.hide()
			rule_label.text = "COMPLETE"
			hint_label.text = "Success"


func _on_shield_changed(remaining: int) -> void:
	if remaining >= GameRules.LEVEL_01_STARTING_SHIELDS:
		shield_one.show()
		shield_one_label.text = "SHIELD 1"
		shield_one.modulate = Color.WHITE
		shield_two.hide()
	elif remaining == 1:
		shield_one.show()
		shield_one_label.text = "SHIELD 1 CLEARED"
		shield_one.modulate = Color(1.0, 1.0, 1.0, 0.62)
		shield_two.show()
	else:
		shield_one.hide()
		shield_two.hide()


func _set_stage_colors(background_color: Color, highlight_color: Color) -> void:
	phase_background.color = background_color
	phase_highlight.color = highlight_color


func _on_equation_submitted(correct: bool) -> void:
	if _feedback_tween != null and _feedback_tween.is_valid():
		_feedback_tween.kill()

	equation_label.modulate = Color("#8FE3C1") if correct else Color("#FF8D86")
	_feedback_tween = create_tween()
	_feedback_tween.tween_property(equation_label, "modulate", Color.WHITE, 0.25)


func _operand_text(snapshot_operands: Array, index: int) -> String:
	if index >= snapshot_operands.size():
		return "_"
	return str(snapshot_operands[index])


func _operation_text(snapshot_operation: GameRules.Operation) -> String:
	return "+" if snapshot_operation == GameRules.Operation.ADD else "-"
