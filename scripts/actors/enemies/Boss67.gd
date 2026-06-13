class_name Boss67
extends Node2D

@export var body_visual_path: NodePath = NodePath("BodyVisual")
@export var label_path: NodePath = NodePath("Label")
@export var spawns_path: NodePath = NodePath("ProjectileSpawns")

var _body_visual: CanvasItem = null
var _label: Label = null
var _spawns_node: Node2D = null
var _current_phase = GameRules.BossPhase.HIDDEN


func _ready() -> void:
	_body_visual = get_node_or_null(body_visual_path) as CanvasItem
	_label = get_node_or_null(label_path) as Label
	_spawns_node = get_node_or_null(spawns_path) as Node2D
	_connect_signals()
	_apply_phase(_current_phase)


func get_spawn_positions() -> Array[Vector2]:
	if _spawns_node == null:
		return []
	var positions: Array[Vector2] = []
	for child in _spawns_node.get_children():
		if child is Marker2D:
			positions.append(child.global_position)
	return positions


func _connect_signals() -> void:
	var ge: Node = get_node_or_null(^"/root/GameEvents")
	if ge == null:
		return
	if ge.has_signal(&"boss_phase_changed"):
		_connect_optional(ge, &"boss_phase_changed", Callable(self, &"_on_boss_phase_changed"))
	if ge.has_signal(&"powerup_started"):
		_connect_optional(ge, &"powerup_started", Callable(self, &"_on_powerup_started"))
	if ge.has_signal(&"powerup_finished"):
		_connect_optional(ge, &"powerup_finished", Callable(self, &"_on_powerup_finished"))


func _connect_optional(source: Node, signal_name: StringName, target: Callable) -> void:
	if not source.has_signal(signal_name):
		return
	if not source.is_connected(signal_name, target):
		source.connect(signal_name, target)


func _on_boss_phase_changed(phase: GameRules.BossPhase) -> void:
	_current_phase = phase
	_apply_phase(phase)


func _on_powerup_started(kind: StringName, _seconds: float) -> void:
	if kind == &"slow":
		modulate = Color(0.7, 0.7, 0.9, 1)


func _on_powerup_finished(kind: StringName) -> void:
	if kind == &"slow":
		modulate = Color.WHITE


func _apply_phase(phase: GameRules.BossPhase) -> void:
	var visible_boss: bool = (
		phase != GameRules.BossPhase.HIDDEN
		and phase != GameRules.BossPhase.DEFEATED
	)
	if _body_visual != null:
		_body_visual.visible = visible_boss
	if _label != null:
		_label.visible = visible_boss

	if phase == GameRules.BossPhase.LAND_PURPLE:
		if _label != null:
			_label.modulate = Color(0.7, 0.3, 1, 1)
	elif phase == GameRules.BossPhase.WATER:
		if _label != null:
			_label.modulate = Color(0.3, 0.6, 1, 1)
	else:
		if _label != null:
			_label.modulate = Color.WHITE
