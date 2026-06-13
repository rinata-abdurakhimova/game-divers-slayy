extends Control

@onready var movement_hint: Control = %MovementHint
@onready var score_hint: Control = %ScoreHint
@onready var action_hint: Control = %ActionHint

var _movement_seen: bool = false
var _score_change_seen: bool = false


func _ready() -> void:
	GameEvents.run_started.connect(_on_run_started)
	GameEvents.score_operation_applied.connect(_on_score_operation_applied)
	GameEvents.water_started.connect(_on_water_started)


func _unhandled_input(event: InputEvent) -> void:
	if not visible or _movement_seen:
		return
	if event.is_action_pressed(&"move_left") or event.is_action_pressed(&"move_right") \
		or event.is_action_pressed(&"jump"):
		_movement_seen = true
		movement_hint.hide()
		score_hint.show()


func _on_run_started() -> void:
	_movement_seen = false
	_score_change_seen = false
	movement_hint.show()
	score_hint.hide()
	action_hint.hide()


func _on_score_operation_applied(
	_operation: StringName,
	_value_cents: int,
	_source: StringName
) -> void:
	if _score_change_seen:
		return
	_score_change_seen = true
	score_hint.hide()
	action_hint.show()
	var tween: Tween = create_tween()
	tween.tween_interval(3.0)
	tween.tween_callback(action_hint.hide)


func _on_water_started(
	_variant: GameRules.WaterVariant,
	_complication: GameRules.WaterComplication,
	_seconds: float
) -> void:
	movement_hint.hide()
	score_hint.hide()
	action_hint.hide()
