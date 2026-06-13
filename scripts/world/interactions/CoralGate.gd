class_name CoralGate
extends StaticBody2D

var is_open: bool = false


func open() -> void:
	if is_open:
		return
	is_open = true
	$CollisionShape2D.set_deferred(&"disabled", true)
	$Visual.color = Color(0.3, 0.8, 0.5, 0.3)


func close() -> void:
	if not is_open:
		return
	is_open = false
	$CollisionShape2D.set_deferred(&"disabled", false)
