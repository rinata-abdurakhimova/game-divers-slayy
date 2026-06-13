extends SceneTree


func _initialize() -> void:
	assert(not WaterRuleService.should_unlock_purple_projectiles(17))
	assert(WaterRuleService.should_unlock_purple_projectiles(18))
	assert(not WaterRuleService.should_start_first_water(27))
	assert(WaterRuleService.should_start_first_water(28))
	assert(WaterRuleService.water_duration_seconds() == 10.0)

	assert(not WaterRuleService.can_land_pickup_trigger_water(5))
	assert(WaterRuleService.can_land_pickup_trigger_water(6))
	assert(WaterRuleService.can_land_pickup_trigger_water(7))

	assert(WaterRuleService.should_retrigger_water_from_land_pickup(6, true, false, true))
	assert(not WaterRuleService.should_retrigger_water_from_land_pickup(6, false, false, true))
	assert(not WaterRuleService.should_retrigger_water_from_land_pickup(6, true, true, true))
	assert(not WaterRuleService.should_retrigger_water_from_land_pickup(6, true, false, false))
	assert(not WaterRuleService.should_retrigger_water_from_land_pickup(5, true, false, true))

	assert(WaterRuleService.land_pickup_operations().size() == 6)
	assert(WaterRuleService.land_boss_projectile_operations().size() == 3)
	assert(WaterRuleService.water_variants().size() == 3)

	_assert_operation_labels(
		WaterRuleService.boss_operations_for_water(GameRules.WaterVariant.WATER_A),
		["*1.15", "*1.2", "*1.3"]
	)
	_assert_operation_labels(
		WaterRuleService.floor_operations_for_water(GameRules.WaterVariant.WATER_A),
		["-10", "-12", "-8", "-6"]
	)
	_assert_operation_labels(
		WaterRuleService.boss_operations_for_water(GameRules.WaterVariant.WATER_B),
		["+3", "+5", "+6", "+7"]
	)
	_assert_operation_labels(
		WaterRuleService.floor_operations_for_water(GameRules.WaterVariant.WATER_B),
		["*0.5", "*0.2", "*0.3", "*0"]
	)
	_assert_operation_labels(
		WaterRuleService.boss_operations_for_water(GameRules.WaterVariant.WATER_C),
		["-5", "-1", "-2", "-7", "-10"]
	)
	_assert_operation_labels(
		WaterRuleService.floor_operations_for_water(GameRules.WaterVariant.WATER_C),
		["*2", "*6", "*3", "*1"]
	)

	var snapshot: Dictionary = WaterRuleService.water_rule_snapshot(GameRules.WaterVariant.WATER_B)
	assert(snapshot["variant"] == GameRules.WaterVariant.WATER_B)
	assert(snapshot["duration_seconds"] == 10.0)
	assert((snapshot["boss_operations"] as Array).size() == 4)
	assert((snapshot["floor_operations"] as Array).size() == 4)

	quit()


func _assert_operation_labels(operations: Array[Dictionary], expected_labels: Array[String]) -> void:
	assert(operations.size() == expected_labels.size())
	for index: int in expected_labels.size():
		assert(operations[index]["label"] == expected_labels[index])
