extends SceneTree

const PROJECTILE_SCENE := preload("res://scenes/actors/numbers/BossProjectile.tscn")
const PICKUP_SCENE := preload("res://scenes/actors/numbers/ScorePickup.tscn")


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
	var boss: Node2D = current_scene.get_node(^"Actors/Boss67") as Node2D
	var camera: Camera2D = current_scene.get_node(^"Camera2D") as Camera2D
	var controller: Node = current_scene.get_node(^"LevelController")
	var safe_wall: StaticBody2D = current_scene.get_node(^"SafeWall") as StaticBody2D
	var safe_zone: Node2D = current_scene.get_node(^"SafeZone") as Node2D
	var water_overlay: CanvasItem = current_scene.get_node(^"WaterOverlay") as CanvasItem
	var land_background: Control = current_scene.get_node(
		^"BackgroundCanvas/BackgroundRoot/LandBackground"
	) as Control
	var pickups: Node2D = current_scene.get_node(^"Pickups") as Node2D
	var projectiles: Node2D = current_scene.get_node(^"Projectiles") as Node2D
	assert(player != null and boss != null and camera != null and controller != null)
	assert(not boss.get_node(^"BodyVisual").visible)
	assert(not safe_wall.visible)
	assert(safe_zone.visible)
	assert(not water_overlay.visible)
	assert(land_background != null)
	assert(is_equal_approx(land_background.anchor_right, 1.0))
	assert(is_equal_approx(land_background.anchor_bottom, 1.0))

	await _physics_frames(2)
	var safe_camera_x: float = camera.global_position.x
	Input.action_press(&"move_right")
	await _physics_frames(80)
	Input.action_release(&"move_right")
	assert(player.global_position.x > 320.0)
	assert(player.global_position.x < 360.0)
	assert(is_equal_approx(camera.global_position.x, safe_camera_x))
	assert(boss.get_node(^"BodyVisual").visible == false)

	controller.call(&"_on_safe_trigger", player)
	assert(not safe_zone.visible)
	assert(boss.get_node(^"BodyVisual").visible)
	assert(game_state.get("boss_phase") == GameRules.BossPhase.LAND_WHITE)
	controller.call(&"_process", 0.0)
	assert(is_equal_approx(camera.global_position.x, player.global_position.x))
	assert(boss.global_position.x > player.global_position.x)
	for child: Node in controller.get_children():
		if child is Timer:
			(child as Timer).stop()

	player.global_position = Vector2(-600, 555)
	player.velocity = Vector2(-200, 0)
	controller.call(&"_process", 0.0)
	assert(player.global_position.x > 1900.0)

	player.global_position = Vector2(864, 555)
	player.velocity = Vector2.ZERO
	await _physics_frames(2)
	assert(player.is_on_floor())
	Input.action_press(&"move_right")
	Input.action_press(&"jump")
	await _physics_frames(20)
	Input.action_release(&"jump")
	await _physics_frames(40)
	Input.action_release(&"move_right")
	assert(player.global_position.x > 620.0)
	assert(player.global_position.y < 648.0)

	var pickup: Area2D = PICKUP_SCENE.instantiate() as Area2D
	pickup.set(&"value_cents", 200)
	pickups.add_child(pickup)
	pickup.global_position = player.global_position
	await _physics_frames(2)
	assert(game_state.get("score_cents") == 300)

	var white: Area2D = PROJECTILE_SCENE.instantiate() as Area2D
	white.set(&"speed", 120.0)
	white.set(&"is_purple", false)
	projectiles.add_child(white)
	white.global_position = Vector2(500, 576)
	await _physics_frames(80)
	assert(not is_instance_valid(white))

	var purple: Area2D = PROJECTILE_SCENE.instantiate() as Area2D
	purple.set(&"speed", 120.0)
	purple.set(&"is_purple", true)
	projectiles.add_child(purple)
	purple.global_position = Vector2(500, 200)
	await _physics_frames(80)
	assert(is_instance_valid(purple))
	assert(purple.global_position.x < 384.0)
	purple.queue_free()

	player.global_position = Vector2(864 + 18 * 48, 520)
	controller.call(&"_process", 0.0)
	assert(game_state.get("distance_blocks") >= 18)
	assert(game_state.get("boss_phase") == GameRules.BossPhase.LAND_PURPLE)

	game_state.call(&"apply_score_operation", GameRules.SCORE_OPERATION_ADD, 500, &"test")
	assert(game_state.get("phase") != GameRules.RunPhase.WATER)

	player.global_position = Vector2(864 + 28 * 48, 520)
	controller.call(&"_process", 0.0)
	assert(game_state.get("phase") == GameRules.RunPhase.WATER)
	assert(game_state.get("water_seconds_left") > 19.9)
	assert(game_state.get("boss_phase") == GameRules.BossPhase.WATER)
	assert(game_state.get("water_variant") == GameRules.WaterVariant.WATER_A)
	var water_complication: int = game_state.get("water_complication")
	assert(water_complication == GameRules.WaterComplication.REVERSED_CONTROLS \
		or water_complication == GameRules.WaterComplication.INVERTED_GRAVITY \
		or water_complication == GameRules.WaterComplication.NONE)
	assert(water_overlay.visible)

	controller.call(&"_spawn_pickup")
	var water_pickup: Node = pickups.get_child(pickups.get_child_count() - 1)
	assert(water_pickup.get("operation") == GameRules.SCORE_OPERATION_SUBTRACT)
	assert(water_pickup.get("value_cents") in [1000, 1200, 800, 600])

	controller.call(&"_spawn_projectile")
	var water_projectile: Node = projectiles.get_child(projectiles.get_child_count() - 1)
	assert(water_projectile.get("operation") == GameRules.SCORE_OPERATION_MULTIPLY)
	assert(water_projectile.get("value_cents") in [115, 120, 130])

	game_state.call(&"finish_water_event")
	assert(game_state.get("phase") == GameRules.RunPhase.LAND)
	assert(not water_overlay.visible)
	game_state.call(&"apply_score_operation", GameRules.SCORE_OPERATION_ADD, 600, &"score_pickup")
	assert(game_state.get("phase") == GameRules.RunPhase.LAND)
	controller.set(&"_water_cooldown_left", 0.0)
	game_state.call(&"apply_score_operation", GameRules.SCORE_OPERATION_ADD, 500, &"score_pickup")
	assert(game_state.get("phase") == GameRules.RunPhase.WATER)

	current_scene.queue_free()
	await process_frame
	quit()


func _physics_frames(count: int) -> void:
	for _frame: int in count:
		await physics_frame
