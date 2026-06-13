class_name EquationAltar
extends Area2D

@export var phase: GameRules.Phase = GameRules.Phase.LAND

var active: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	var gs: Node = get_node_or_null(^"/root/GameState")
	if gs != null:
		active = gs.get("phase") == phase
	var ge: Node = get_node_or_null(^"/root/GameEvents")
	if ge == null:
		return
	if not ge.has_signal(&"phase_changed"):
		return
	var callable: Callable = Callable(self, &"_on_phase_changed")
	if not ge.is_connected(&"phase_changed", callable):
		ge.connect(&"phase_changed", callable)


func _on_phase_changed(new_phase: GameRules.Phase) -> void:
	active = new_phase == phase


func _on_body_entered(body: Node) -> void:
	if not active:
		return
	if not body is CharacterBody2D:
		return
	var gs: Node = get_node_or_null(^"/root/GameState")
	if gs == null:
		return
	if gs.has_method(&"submit_equation"):
		gs.submit_equation()
