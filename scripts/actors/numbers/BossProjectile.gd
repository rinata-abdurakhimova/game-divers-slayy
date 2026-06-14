class_name BossProjectile
extends Area2D

@export var speed: float = 100.0
@export var value_cents: int = 50
@export var operation: StringName = GameRules.SCORE_OPERATION_MULTIPLY
@export var is_purple: bool = false

var _life_seconds: float = 12.0
var _hit: bool = false
var _direction: Vector2 = Vector2(-1.0, 0.3)   # default: fly left and slightly down

# Collision layer constants matching INTEGRATION_CONTRACT.md:
#   Layer 1  - player body
#   Layer 2  - solid terrain (blocks, floor)
#   Layer 6  - water/floor boundary (for purple destruction)
const LAYER_PLAYER: int  = 1       # bit 0
const LAYER_TERRAIN: int = 2       # bit 1
const LAYER_FLOOR: int   = 32      # bit 5  (layer 6 in 1-indexed = bit 5 in 0-indexed)


func _ready() -> void:
	# White: collides with player (layer 1) and terrain (layer 2).
	# Purple: collides with player (layer 1) and floor boundary (layer 6) only — ignores blocks.
	if is_purple:
		collision_mask = LAYER_PLAYER | LAYER_FLOOR
	else:
		collision_mask = LAYER_PLAYER | LAYER_TERRAIN

	body_entered.connect(_on_body_entered)
	_update_visual()


func _process(delta: float) -> void:
	if _hit:
		return
	# Move along the direction vector toward the target.
	position += _direction * speed * delta
	_life_seconds -= delta
	if _life_seconds <= 0.0 or global_position.y > 750.0 or global_position.y < -100.0:
		queue_free()


func set_direction(dir: Vector2) -> void:
	_direction = dir.normalized() if dir.length_squared() > 0.001 else Vector2(-1.0, 0.3)


func _on_body_entered(body: Node) -> void:
	if _hit:
		return

	# Hit player → apply score operation.
	if body is Player:
		_hit = true
		_apply_operation()
		queue_free()
		return

	# White projectile hits any solid terrain block → destroy without applying score.
	if not is_purple and body is StaticBody2D:
		queue_free()
		return

	# Purple projectile: only destroyed by the floor/water-boundary layer (bit 5).
	if is_purple and body is StaticBody2D:
		if body.collision_layer & LAYER_FLOOR:
			queue_free()
			return
		# Any other block (terrain) → purple passes through; do nothing.


func _apply_operation() -> void:
	var gs: Node = get_node_or_null(^"/root/GameState")
	if gs == null or not gs.has_method(&"apply_score_operation"):
		return
	gs.apply_score_operation(operation, value_cents, &"boss_projectile")


func _update_visual() -> void:
	var bg: Polygon2D = get_node_or_null(^"Bg") as Polygon2D
	var label: Label   = get_node_or_null(^"Label") as Label

	if bg != null:
		bg.color = Color(0.57, 0.27, 1.0, 1.0) if is_purple else Color(1.0, 1.0, 1.0, 1.0)

	if label != null:
		label.text = _operation_text()
		# Make numbers highly readable over both sky and water backgrounds.
		var font_color: Color
		var outline_color: Color
		if is_purple:
			font_color    = Color(1.0, 1.0, 1.0, 1.0)
			outline_color = Color(0.25, 0.0, 0.45, 1.0)
		else:
			font_color    = Color(0.9, 0.05, 0.05, 1.0)   # red text, very readable on white
			outline_color = Color(1.0, 1.0, 1.0, 1.0)      # white outline
		label.add_theme_color_override(&"font_color", font_color)
		label.add_theme_color_override(&"font_outline_color", outline_color)
		label.add_theme_constant_override(&"outline_size", 4)
		# Large font size for readability.
		label.add_theme_font_size_override(&"font_size", 22)


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
