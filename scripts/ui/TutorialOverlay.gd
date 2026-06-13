extends Control

@onready var arrow_hint: Label = %ArrowHint
@onready var collection_hint: Label = %CollectionHint
@onready var submission_hint: Label = %SubmissionHint
@onready var rule_change_banner: Label = %RuleChangeBanner

var _movement_seen: bool = false


func _ready() -> void:
	collection_hint.hide()
	submission_hint.hide()
	rule_change_banner.hide()

	if GameEvents.equation_changed.is_connected(_on_equation_changed):
		GameEvents.equation_changed.disconnect(_on_equation_changed)
	GameEvents.equation_changed.connect(_on_equation_changed)

	if GameEvents.tide_finished.is_connected(_on_tide_finished):
		GameEvents.tide_finished.disconnect(_on_tide_finished)
	GameEvents.tide_finished.connect(_on_tide_finished)


func _unhandled_input(event: InputEvent) -> void:
	if _movement_seen:
		return
	if event.is_action_pressed(&"move_left") or event.is_action_pressed(&"move_right") \
		or event.is_action_pressed(&"move_up") or event.is_action_pressed(&"move_down"):
		_movement_seen = true
		arrow_hint.hide()
		collection_hint.show()
		get_viewport().set_input_as_handled()


func _on_equation_changed(_snapshot: Dictionary) -> void:
	var operands: Array = GameState.operands
	if operands.size() == GameRules.MAX_OPERAND_SLOTS:
		submission_hint.show()


func _on_tide_finished() -> void:
	rule_change_banner.show()
	collection_hint.hide()
	submission_hint.hide()
