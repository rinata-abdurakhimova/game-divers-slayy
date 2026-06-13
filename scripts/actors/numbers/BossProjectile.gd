class_name BossProjectile
extends Area2D

@export var speed: float = 120.0
@export var value_cents: int = 50
@export var operation: StringName = GameRules.SCORE_OPERATION_MULTIPLY
@export var is_purple: bool = false

var _life_seconds: float = 10.0
var _hit: bool = false


func _ready() -> void:
	if is_purple:
		collision_mask = 1 | 32
	else:
		collision_mask = 1 | 2
	_update_visual()
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	if _hit:
		return
	position.x -= speed * delta
	position.y += 20.0 * delta
	_life_seconds -= delta
	if _life_seconds <= 0.0 or global_position.y > 680.0:
		queue_free()


func _on_body_entered(body: Node) -> void:
	if _hit:
		return

	if body is Player:
		_hit = true
		_apply_operation()
		queue_free()
		return

	if not is_purple and body is StaticBody2D:
		queue_free()
		return

	if is_purple and body is StaticBody2D:
		var layer: int = body.collision_layer
		if layer & 32:
			queue_free()
			return


func _apply_operation() -> void:
	var gs: Node = get_node_or_null(^"/root/GameState")
	if gs == null:
		return
	if not gs.has_method(&"apply_score_operation"):
		return
	gs.apply_score_operation(operation, value_cents, &"boss_projectile")


func _update_visual() -> void:
	var bg: Polygon2D = get_node_or_null(^"Bg") as Polygon2D
	var label: Label = get_node_or_null(^"Label") as Label
	if bg != null:
		bg.color = Color(0.57, 0.27, 1.0, 1.0) if is_purple else Color(1.0, 1.0, 1.0, 1.0)
	if label != null:
		label.text = _operation_text()
		var text_color: Color = Color(1.0, 1.0, 1.0, 1.0) if is_purple else Color(0.85, 0.05, 0.05, 1.0)
		var outline_color: Color = Color(0.18, 0.02, 0.3, 1.0) if is_purple else Color(1.0, 1.0, 1.0, 1.0)
		label.add_theme_color_override(&"font_color", text_color)
		label.add_theme_color_override(&"font_outline_color", outline_color)


func _operation_text() -> String:
	var amount: float = float(value_cents) / 100.0
	var amount_text: String = ("%0.2f" % amount).trim_suffix("0").trim_suffix(".")
	match operation:
		GameRules.SCORE_OPERATION_ADD:
			return "+%s" % amount_text
		GameRules.SCORE_OPERATION_SUBTRACT:
			return "-%s" % amount_text
		GameRules.SCORE_OPERATION_MULTIPLY:
			return "x%s" % amount_text
	return amount_text
