extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var game_state: Node = root.get_node(^"GameState")
	game_state.call(&"reset_boss_67_run")

	var change_error: Error = change_scene_to_file(
		"res://scenes/main/Boss67FallbackLevel.tscn"
	)
	assert(change_error == OK)
	await scene_changed
	await process_frame

	var player: CharacterBody2D = current_scene.get_node(^"Player") as CharacterBody2D
	assert(player != null)
	var spawn_y: float = player.global_position.y
	await _physics_frames(30)
	assert(player.global_position.y > spawn_y)
	assert(player.is_on_floor())

	var landed_x: float = player.global_position.x
	Input.action_press(&"move_right")
	await _physics_frames(12)
	Input.action_release(&"move_right")
	assert(player.global_position.x > landed_x)

	var floor_y: float = player.global_position.y
	Input.action_press(&"jump")
	await physics_frame
	Input.action_release(&"jump")
	await _physics_frames(4)
	assert(player.global_position.y < floor_y)
	assert(player.velocity.y < 0.0)

	await _physics_frames(50)
	assert(player.is_on_floor())
	assert(absf(player.global_position.y - floor_y) < 1.0)

	current_scene.queue_free()
	await process_frame
	quit()


func _physics_frames(count: int) -> void:
	for _frame: int in count:
		await physics_frame
