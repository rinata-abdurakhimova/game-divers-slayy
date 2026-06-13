extends Control

@onready var target_label: Label = %TargetLabel
@onready var equation_label: Label = %EquationLabel
@onready var rule_label: Label = %RuleLabel
@onready var shield_label: Label = %ShieldLabel
@onready var hint_label: Label = %HintLabel

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
			rule_label.text = "COMBINE"
			hint_label.text = "Find two numbers that make 10"
		GameRules.Phase.TRANSITION:
			rule_label.text = "CHANGING..."
			hint_label.text = "The tide is changing the rule"
		GameRules.Phase.WATER:
			rule_label.text = "SPLIT"
			hint_label.text = "First number minus second number"
		GameRules.Phase.COMPLETE:
			rule_label.text = "COMPLETE"
			hint_label.text = "Guardian 10 defeated"


func _on_shield_changed(remaining: int) -> void:
	shield_label.text = "SHIELDS %s" % "◆".repeat(maxi(0, remaining))


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
