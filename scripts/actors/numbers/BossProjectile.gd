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
