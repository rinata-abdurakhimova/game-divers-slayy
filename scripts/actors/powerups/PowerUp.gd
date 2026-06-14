class_name PowerUp
extends Area2D

@export var kind: StringName = &"slow"
@export var duration_seconds: float = GameRules.POWERUP_DURATION_SECONDS

var _collected: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_update_visual()


func _on_body_entered(body: Node) -> void:
	if _collected:
		return
	if not body is Player:
		return

	var gs: Node = get_node_or_null(^"/root/GameState")
	if gs == null:
		return
	if not gs.has_method(&"activate_powerup"):
		return

	_collected = true
	gs.activate_powerup(kind, duration_seconds)
	queue_free()


func _update_visual() -> void:
	var icon: Polygon2D = get_node_or_null(^"Icon") as Polygon2D
	var label: Label = get_node_or_null(^"Label") as Label
	if icon == null:
		return
	match kind:
		&"slow":
			icon.color = Color(1, 0.85, 0.2, 1)
			if label != null:
				label.text = "★"
		&"double_jump":
			icon.color = Color(0.2, 0.9, 0.3, 1)
			if label != null:
				label.text = "↑"
