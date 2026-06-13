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
		label.text = ScoreServiceScript.format_score(value_cents)
