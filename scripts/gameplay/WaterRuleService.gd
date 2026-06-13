class_name WaterRuleService
extends RefCounted

const ScoreServiceScript = preload("res://scripts/gameplay/ScoreService.gd")


static func should_start_first_water(distance_blocks: int) -> bool:
	return distance_blocks >= GameRules.FIRST_WATER_DISTANCE_BLOCKS


static func should_unlock_purple_projectiles(distance_blocks: int) -> bool:
	return distance_blocks >= GameRules.FIRST_PURPLE_DISTANCE_BLOCKS


static func can_land_pickup_trigger_water(raw_land_value: int) -> bool:
	for divisor: int in GameRules.WATER_RETRIGGER_DIVISORS:
		if divisor != 0 and raw_land_value % divisor == 0:
			return true
	return false


static func should_retrigger_water_from_land_pickup(
	raw_land_value: int,
	first_water_finished: bool,
	water_active: bool,
	cooldown_ready: bool
) -> bool:
	return first_water_finished \
		and not water_active \
		and cooldown_ready \
		and can_land_pickup_trigger_water(raw_land_value)


static func water_duration_seconds() -> float:
	return GameRules.WATER_DURATION_SECONDS


static func water_variants() -> Array[GameRules.WaterVariant]:
	return [
		GameRules.WaterVariant.WATER_A,
		GameRules.WaterVariant.WATER_B,
		GameRules.WaterVariant.WATER_C,
	]


static func land_pickup_operations() -> Array[Dictionary]:
	var operations: Array[Dictionary] = []
	for value_cents: int in GameRules.LAND_PICKUP_VALUES_CENTS:
		operations.append(_operation(GameRules.SCORE_OPERATION_ADD, value_cents))
	return operations


static func land_boss_projectile_operations() -> Array[Dictionary]:
	var operations: Array[Dictionary] = []
	for multiplier_cents: int in GameRules.LAND_BOSS_MULTIPLIERS_CENTS:
		operations.append(_operation(GameRules.SCORE_OPERATION_MULTIPLY, multiplier_cents))
	return operations


static func boss_operations_for_water(variant: GameRules.WaterVariant) -> Array[Dictionary]:
	match variant:
		GameRules.WaterVariant.WATER_A:
			return _multiply_operations(GameRules.WATER_A_BOSS_MULTIPLIERS_CENTS)
		GameRules.WaterVariant.WATER_B:
			return _add_operations(GameRules.WATER_B_BOSS_VALUES_CENTS)
		GameRules.WaterVariant.WATER_C:
			return _add_operations(GameRules.WATER_C_BOSS_VALUES_CENTS)
		_:
			return []


static func floor_operations_for_water(variant: GameRules.WaterVariant) -> Array[Dictionary]:
	match variant:
		GameRules.WaterVariant.WATER_A:
			return _add_operations(GameRules.WATER_A_FLOOR_VALUES_CENTS)
		GameRules.WaterVariant.WATER_B:
			return _multiply_operations(GameRules.WATER_B_FLOOR_MULTIPLIERS_CENTS)
		GameRules.WaterVariant.WATER_C:
			return _multiply_operations(GameRules.WATER_C_FLOOR_MULTIPLIERS_CENTS)
		_:
			return []


static func water_rule_snapshot(variant: GameRules.WaterVariant) -> Dictionary:
	return {
		"variant": variant,
		"duration_seconds": GameRules.WATER_DURATION_SECONDS,
		"boss_operations": boss_operations_for_water(variant),
		"floor_operations": floor_operations_for_water(variant),
	}


static func _add_operations(values_cents: Array[int]) -> Array[Dictionary]:
	var operations: Array[Dictionary] = []
	for value_cents: int in values_cents:
		var operation: StringName = GameRules.SCORE_OPERATION_ADD
		var normalized_value: int = value_cents
		if value_cents < 0:
			operation = GameRules.SCORE_OPERATION_SUBTRACT
			normalized_value = absi(value_cents)
		operations.append(_operation(operation, normalized_value))
	return operations


static func _multiply_operations(values_cents: Array[int]) -> Array[Dictionary]:
	var operations: Array[Dictionary] = []
	for value_cents: int in values_cents:
		operations.append(_operation(GameRules.SCORE_OPERATION_MULTIPLY, value_cents))
	return operations


static func _operation(operation: StringName, value_cents: int) -> Dictionary:
	return {
		"operation": operation,
		"value_cents": value_cents,
		"label": ScoreServiceScript.operation_label(operation, value_cents),
	}
