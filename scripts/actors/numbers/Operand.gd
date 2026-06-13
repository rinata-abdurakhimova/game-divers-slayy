class_name Operand
extends Area2D

@export var value: int = 0

var _collected: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if _collected:
		return
	if not body is CharacterBody2D:
		return

	var gs: Node = get_node_or_null(^"/root/GameState")
	if gs == null:
		return
	if not gs.has_method(&"try_collect_operand"):
		return

	if gs.try_collect_operand(value):
		_collected = true
		hide()
		set_deferred(&"monitoring", false)
