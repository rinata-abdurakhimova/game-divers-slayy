class_name ScorePickup
extends Area2D

const ScoreServiceScript = preload("res://scripts/gameplay/ScoreService.gd")

@export var value_cents: int = 100
@export var operation: StringName = GameRules.SCORE_OPERATION_ADD

var _collected: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_update_label()


func set_value(cents: int) -> void:
	value_cents = cents
	_update_label()


func _on_body_entered(body: Node) -> void:
	if _collected:
		return
	if not body is Player:
		return

	var gs: Node = get_node_or_null(^"/root/GameState")
	if gs == null:
		return
	if not gs.has_method(&"apply_score_operation"):
		return

	_collected = true
	gs.apply_score_operation(operation, value_cents, &"score_pickup")
	queue_free()


func _update_label() -> void:
	var label: Label = get_node_or_null(^"Label")
	if label != null:
		label.text = _operation_text()
	var bg: Polygon2D = get_node_or_null(^"Bg") as Polygon2D
	if bg != null:
		match operation:
			GameRules.SCORE_OPERATION_ADD:
				bg.color = Color(0.2, 0.85, 0.55, 1.0)
			GameRules.SCORE_OPERATION_SUBTRACT:
				bg.color = Color(0.2, 0.45, 0.95, 1.0)
			GameRules.SCORE_OPERATION_MULTIPLY:
				bg.color = Color(0.95, 0.75, 0.15, 1.0)


func _operation_text() -> String:
	var amount_text: String = ScoreServiceScript.format_score(value_cents)
	match operation:
		GameRules.SCORE_OPERATION_ADD:
			return "+%s" % amount_text
		GameRules.SCORE_OPERATION_SUBTRACT:
			return "-%s" % amount_text
		GameRules.SCORE_OPERATION_MULTIPLY:
			return "x%s" % amount_text
	return amount_text
