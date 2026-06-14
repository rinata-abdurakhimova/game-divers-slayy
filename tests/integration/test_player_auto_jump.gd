extends SceneTree

const PLAYER_SCENE := preload("res://scenes/actors/Player.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var game_state: Node = root.get_node(^"GameState")
	game_state.call(&"reset_boss_67_run")

	var room := Node2D.new()
	root.add_child(room)

	var terrain := StaticBody2D.new()
	terrain.collision_layer = 2
	room.add_child(terrain)
	_add_box(terrain, Vector2(320, 590), Vector2(640, 40))
	_add_box(terrain, Vector2(250, 546), Vector2(48, 48))

	var player: CharacterBody2D = PLAYER_SCENE.instantiate() as CharacterBody2D
	room.add_child(player)
	player.global_position = Vector2(120, 555)
	await _physics_frames(3)
	assert(player.is_on_floor())

	var start_y: float = player.global_position.y
	Input.action_press(&"move_right")
	await _physics_frames(35)
	Input.action_release(&"move_right")

	assert(player.global_position.x > 210.0)
	assert(player.global_position.y < start_y - 10.0 or player.velocity.y < 0.0)

	room.queue_free()
	await process_frame
	quit()


func _add_box(parent: StaticBody2D, position: Vector2, size: Vector2) -> void:
	var collision := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = size
	collision.shape = rectangle
	collision.position = position
	parent.add_child(collision)


func _physics_frames(count: int) -> void:
	for _frame: int in count:
		await physics_frame
