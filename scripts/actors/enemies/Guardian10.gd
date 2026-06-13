class_name Guardian10
extends Node2D

@export var shield_bar_1_path: NodePath = ^"ShieldBar1"
@export var shield_bar_2_path: NodePath = ^"ShieldBar2"
@export var body_visual_path: NodePath = ^"BodyVisual"

@export var idle_body_color: Color = Color(0.6, 0.1, 0.1, 1)
@export var hurt_body_color: Color = Color(0.8, 0.3, 0.0, 1)
@export var defeated_body_color: Color = Color(0.3, 0.3, 0.3, 1)

var _shield_bar_1: CanvasItem = null
var _shield_bar_2: CanvasItem = null
var _body_visual: CanvasItem = null


func _ready() -> void:
	_shield_bar_1 = get_node_or_null(shield_bar_1_path) as CanvasItem
	_shield_bar_2 = get_node_or_null(shield_bar_2_path) as CanvasItem
	_body_visual = get_node_or_null(body_visual_path) as CanvasItem
	_connect_signals()
	_update_visual(GameRules.LEVEL_01_STARTING_SHIELDS)


func _connect_signals() -> void:
	var ge: Node = get_node_or_null(^"/root/GameEvents")
	if ge == null:
		return
	if not ge.has_signal(&"shield_changed"):
		return
	var callable: Callable = Callable(self, &"_on_shield_changed")
	if not ge.is_connected(&"shield_changed", callable):
		ge.connect(&"shield_changed", callable)


func _on_shield_changed(remaining: int) -> void:
	_update_visual(remaining)


func _update_visual(remaining: int) -> void:
	if _shield_bar_1 != null:
		_shield_bar_1.visible = remaining >= 1
	if _shield_bar_2 != null:
		_shield_bar_2.visible = remaining >= 2
	if _body_visual == null:
		return
	match remaining:
		2:
			_body_visual.color = idle_body_color
		1:
			_body_visual.color = hurt_body_color
		_:
			_body_visual.color = defeated_body_color
