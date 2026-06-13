extends Control

@onready var arrow_hint: Control = %ArrowHint
@onready var collection_hint: Control = %CollectionHint
@onready var submission_hint: Control = %SubmissionHint
@onready var rule_change_banner: Control = %RuleChangeBanner

var _movement_seen: bool = false
var _water_hint_seen: bool = false


func _ready() -> void:
	collection_hint.hide()
	submission_hint.hide()
	rule_change_banner.hide()

	GameEvents.equation_changed.connect(_on_equation_changed)
	GameEvents.phase_changed.connect(_on_phase_changed)
	_on_equation_changed(GameState.get_equation_snapshot())


func _unhandled_input(event: InputEvent) -> void:
	if _movement_seen:
		return
	if event.is_action_pressed(&"move_left") or event.is_action_pressed(&"move_right") \
		or event.is_action_pressed(&"move_up") or event.is_action_pressed(&"move_down"):
		_movement_seen = true
		arrow_hint.hide()
		collection_hint.show()
		get_viewport().set_input_as_handled()


func _on_equation_changed(snapshot: Dictionary) -> void:
	var operands: Array = snapshot.get("operands", [])
	var current_phase: GameRules.Phase = snapshot.get("phase", GameRules.Phase.LAND)

	if operands.size() == GameRules.MAX_OPERAND_SLOTS:
		submission_hint.show()
		collection_hint.hide()
	elif _movement_seen and current_phase == GameRules.Phase.LAND:
		submission_hint.hide()
		collection_hint.show()


func _on_phase_changed(new_phase: GameRules.Phase) -> void:
	match new_phase:
		GameRules.Phase.TRANSITION:
			collection_hint.hide()
			submission_hint.hide()
		GameRules.Phase.WATER:
			if not _water_hint_seen:
				_water_hint_seen = true
				rule_change_banner.show()
			collection_hint.hide()
			submission_hint.hide()
		GameRules.Phase.COMPLETE:
			hide()
