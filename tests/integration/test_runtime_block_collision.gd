extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var game_state: Node = root.get_node(^"GameState")
	game_state.call(&"reset_boss_67_run")

	var error: Error = change_scene_to_file("res://scenes/world/Boss67Level.tscn")
	assert(error == OK)
	await scene_changed
	await process_frame

	var player: CharacterBody2D = current_scene.get_node(^"Actors/Player") as CharacterBody2D
	var controller: Node = current_scene.get_node(^"LevelController")
	var terrain: StaticBody2D = current_scene.get_node(^"Terrain") as StaticBody2D
	assert(player != null and controller != null and terrain != null)

	controller.call(&"_on_safe_trigger", player)
	await _physics_frames(2)

	var enabled_runtime_shapes: int = 0
	for child: Node in terrain.get_children():
		var shape := child as CollisionShape2D
		if shape != null and child.name != &"MainFloor" and not shape.disabled:
			enabled_runtime_shapes += 1
	assert(enabled_runtime_shapes > 0)

	# Column 22, row 1 has a runtime block centered at x=1032.
	player.set(&"auto_jump_enabled", false)
	player.global_position = Vector2(940, 555)
	player.velocity = Vector2.ZERO
	await _physics_frames(2)
	Input.action_press(&"move_right")
	await _physics_frames(40)
	Input.action_release(&"move_right")
	assert(player.global_position.x < 1002.0)

	current_scene.queue_free()
	await process_frame
	quit()


func _physics_frames(count: int) -> void:
	for _frame: int in count:
		await physics_frame
