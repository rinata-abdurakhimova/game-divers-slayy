class_name ResetShell
extends Area2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if not body is CharacterBody2D:
		return
	var gs: Node = get_node_or_null(^"/root/GameState")
	if gs == null:
		return
	if gs.has_method(&"clear_operands"):
		gs.clear_operands()
