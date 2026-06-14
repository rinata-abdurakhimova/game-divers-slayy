extends SceneTree


func _initialize() -> void:
	call_deferred(&"_run")


func _run() -> void:
	var error: Error = change_scene_to_file("res://scenes/world/Boss67Level.tscn")
	assert(error == OK)
	await scene_changed
	await process_frame

	var controller: Node = current_scene.get_node(^"LevelController")
	var player: CharacterBody2D = current_scene.get_node(^"Actors/Player") as CharacterBody2D
	var pickups: Node2D = current_scene.get_node(^"Pickups") as Node2D
	assert(controller != null and player != null)
	assert(pickups != null)

	controller.call(&"_on_safe_trigger", player)
	await process_frame
	player.global_position = Vector2(1200.0, 520.0)
	controller.call(&"_process", 0.0)
	for child: Node in controller.get_children():
		if child is Timer:
			(child as Timer).stop()

	for _index: int in 2:
		var position: Vector2 = controller.call(&"_random_pickup_position")
		assert(position.is_finite())
		assert(controller.call(&"_is_pickup_position_clear", position))
		var marker := Node2D.new()
		marker.global_position = position
		pickups.add_child(marker)

	var spawned: Array[Node] = pickups.get_children()
	assert(spawned.size() == 9)
	for first_index: int in spawned.size():
		var first: Node2D = spawned[first_index] as Node2D
		for second_index: int in range(first_index + 1, spawned.size()):
			var second: Node2D = spawned[second_index] as Node2D
			assert(absf(first.global_position.x - second.global_position.x) >= 71.9 \
				or absf(first.global_position.y - second.global_position.y) >= 49.9)

	quit()
