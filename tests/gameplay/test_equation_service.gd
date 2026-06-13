extends SceneTree

const CASES: Array[Dictionary] = [
	{
		"operands": [4, 6],
		"operation": GameRules.Operation.ADD,
		"target": 10,
		"expected": true,
	},
	{
		"operands": [6, 4],
		"operation": GameRules.Operation.ADD,
		"target": 10,
		"expected": true,
	},
	{
		"operands": [14, 4],
		"operation": GameRules.Operation.SUBTRACT,
		"target": 10,
		"expected": true,
	},
	{
		"operands": [4, 14],
		"operation": GameRules.Operation.SUBTRACT,
		"target": 10,
		"expected": false,
	},
	{
		"operands": [4],
		"operation": GameRules.Operation.ADD,
		"target": 10,
		"expected": false,
	},
	{
		"operands": [4, 6, 2],
		"operation": GameRules.Operation.ADD,
		"target": 10,
		"expected": false,
	},
	{
		"operands": [],
		"operation": GameRules.Operation.SUBTRACT,
		"target": 10,
		"expected": false,
	},
]


func _initialize() -> void:
	for test_case: Dictionary in CASES:
		var operands: Array[int] = []
		var raw_operands: Array = test_case["operands"]
		for value: int in raw_operands:
			operands.append(value)

		var actual: bool = EquationService.is_valid_submission(
			operands,
			test_case["operation"],
			test_case["target"]
		)
		assert(actual == test_case["expected"])

	assert(EquationService.is_valid_level_01_submission(GameRules.Phase.LAND, _int_array([4, 6])))
	assert(EquationService.is_valid_level_01_submission(GameRules.Phase.WATER, _int_array([14, 4])))
	assert(not EquationService.is_valid_level_01_submission(GameRules.Phase.TRANSITION, _int_array([4, 6])))
	assert(not EquationService.is_valid_level_01_submission(GameRules.Phase.COMPLETE, _int_array([14, 4])))
	quit()


func _int_array(values: Array) -> Array[int]:
	var result: Array[int] = []
	for value: int in values:
		result.append(value)
	return result
