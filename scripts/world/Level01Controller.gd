class_name Level01Controller
extends Node

@export var operand_scene: PackedScene
@export var land_operand_spawns_path: NodePath
@export var active_operands_path: NodePath
@export var coral_gate_path: NodePath
@export var water_scene: PackedScene
@export var container_path: NodePath

var _tide_in_progress: bool = false


func _ready() -> void:
	_connect_signals()
	_spawn_operands_for_phase(GameRules.Phase.LAND)


func _connect_signals() -> void:
	var ge: Node = get_node_or_null(^"/root/GameEvents")
	if ge == null:
		return
	if ge.has_signal(&"equation_submitted"):
		ge.equation_submitted.connect(_on_equation_submitted)
	if ge.has_signal(&"operands_cleared"):
		ge.operands_cleared.connect(_on_operands_cleared)


func _on_equation_submitted(correct: bool) -> void:
	if not correct or _tide_in_progress:
		return

	var gs: Node = get_node_or_null(^"/root/GameState")
	if gs == null:
		return

	var current_phase: int = gs.get("phase")
	match current_phase:
		GameRules.Phase.LAND:
			_open_gate()
			if gs != null and gs.has_method(&"begin_tide_transition"):
				gs.begin_tide_transition()
			GameEvents.tide_started.emit()
			await get_tree().create_timer(GameRules.TIDE_TRANSITION_SECONDS).timeout
			_swap_to_water_scene()


func _on_operands_cleared() -> void:
	var gs: Node = get_node_or_null(^"/root/GameState")
	if gs == null:
		return
	var current_phase: int = gs.get("phase")
	if GameRules.is_submission_phase(current_phase):
		_spawn_operands_for_phase(current_phase)


func _open_gate() -> void:
	var coral_gate: Node = get_node_or_null(coral_gate_path)
	if coral_gate != null and coral_gate.has_method(&"open"):
		coral_gate.open()


func _swap_to_water_scene() -> void:
	if water_scene == null:
		return

	var container: Node = get_node(container_path)
	if container == null:
		return

	var water: Node = water_scene.instantiate()
	container.add_child(water)

	var level_node: Node = get_parent()
	container.remove_child(level_node)
	level_node.queue_free()


func _spawn_operands_for_phase(phase: GameRules.Phase) -> void:
	_clear_active_operands()

	var spawns_node: Node2D = get_node_or_null(land_operand_spawns_path) as Node2D
	var correct: Array[int] = GameRules.LAND_CORRECT_OPERANDS
	var distractors: Array[int] = GameRules.LAND_DISTRACTORS

	if spawns_node == null or operand_scene == null:
		return

	var active: Node2D = get_node_or_null(active_operands_path) as Node2D
	if active == null:
		return

	var values: Array[int] = correct + distractors
	var markers: Array[Node] = spawns_node.get_children()
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


func _clear_active_operands() -> void:
	var active: Node2D = get_node_or_null(active_operands_path) as Node2D
	if active == null:
		return
	for child: Node in active.get_children():
		child.queue_free()
