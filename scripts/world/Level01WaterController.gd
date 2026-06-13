extends Node
class_name Level01WaterController

@export var operand_scene: PackedScene
@export var water_spawns_path: NodePath
@export var active_operands_path: NodePath


func _ready() -> void:
	var gs: Node = get_node_or_null(^"/root/GameState")
	if gs != null and gs.has_method(&"enter_water_phase"):
		gs.enter_water_phase()

	GameEvents.tide_finished.emit()
	_spawn_water_operands()


func _spawn_water_operands() -> void:
	var spawns: Node2D = get_node_or_null(water_spawns_path) as Node2D
	var active: Node2D = get_node_or_null(active_operands_path) as Node2D
	if spawns == null or active == null or operand_scene == null:
		return

	var values: Array[int] = GameRules.WATER_CORRECT_OPERANDS + GameRules.WATER_DISTRACTORS
	var markers: Array[Node] = spawns.get_children()
	var count: int = mini(values.size(), markers.size())

	for i in count:
		var marker: Marker2D = markers[i] as Marker2D
		if marker == null:
			continue
		var operand: Operand = operand_scene.instantiate() as Operand
		if operand == null:
			continue
		operand.value = values[i]
		operand.global_position = marker.global_position
		active.add_child(operand)
