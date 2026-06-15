class_name ScorePickup
extends Area2D

const ScoreServiceScript = preload("res://scripts/gameplay/ScoreService.gd")
const EXPIRY_SECONDS: float = 60.0

@export var value_cents: int = 100
@export var operation: StringName = GameRules.SCORE_OPERATION_ADD

var _collected: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_update_label()
	_start_expiry_timer()


func _start_expiry_timer() -> void:
	var timer := Timer.new()
	timer.wait_time = EXPIRY_SECONDS
	timer.one_shot = true
	timer.timeout.connect(queue_free)
	add_child(timer)
	timer.start()


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
	var glow: Polygon2D = get_node_or_null(^"Glow") as Polygon2D
	var outline: Polygon2D = get_node_or_null(^"Outline") as Polygon2D
	if bg != null:
		match operation:
			GameRules.SCORE_OPERATION_ADD:
				bg.color = Color(0.2, 0.85, 0.55, 1.0)
				if glow != null:
					glow.color = Color(0.3, 1.0, 0.68, 0.28)
				if outline != null:
					outline.color = Color(0.035, 0.22, 0.16, 1.0)
			GameRules.SCORE_OPERATION_SUBTRACT:
				bg.color = Color(0.2, 0.45, 0.95, 1.0)
				if glow != null:
					glow.color = Color(0.35, 0.72, 1.0, 0.28)
				if outline != null:
					outline.color = Color(0.04, 0.12, 0.38, 1.0)
			GameRules.SCORE_OPERATION_MULTIPLY:
				bg.color = Color(0.95, 0.75, 0.15, 1.0)
				if glow != null:
					glow.color = Color(1.0, 0.88, 0.3, 0.3)
				if outline != null:
					outline.color = Color(0.36, 0.22, 0.02, 1.0)


func _operation_text() -> String:
	var amount_text: String = ScoreServiceScript.format_operation_value(value_cents)
	match operation:
		GameRules.SCORE_OPERATION_ADD:
			return "+%s" % amount_text
		GameRules.SCORE_OPERATION_SUBTRACT:
			return "-%s" % amount_text
		GameRules.SCORE_OPERATION_MULTIPLY:
			return "x%s" % amount_text
	return amount_text
