extends Control

@onready var rule_card: Control = %RuleCard
@onready var rule_title: Label = %RuleTitle
@onready var rule_body: Label = %RuleBody


func _ready() -> void:
	hide()
	GameEvents.run_started.connect(_on_run_started)
	GameEvents.water_started.connect(_on_water_started)
	GameEvents.water_finished.connect(_on_water_finished)


func _unhandled_input(event: InputEvent) -> void:
	if visible and rule_card.visible and event.is_action_pressed(&"action"):
		rule_card.hide()
		get_viewport().set_input_as_handled()


func _on_run_started() -> void:
	hide()
	rule_card.show()


func _on_water_started(
	variant: GameRules.WaterVariant,
	complication: GameRules.WaterComplication,
	_seconds: float
) -> void:
	rule_title.text = "PINK TIDE: RULES CHANGED"
	rule_body.text = _rule_description(variant, complication)
	rule_card.show()
	show()


func _on_water_finished() -> void:
	hide()


func _rule_description(
	variant: GameRules.WaterVariant,
	complication: GameRules.WaterComplication
) -> String:
	var description: String
	match variant:
		GameRules.WaterVariant.WATER_A:
			description = "Boss numbers multiply.\nFloor numbers subtract."
		GameRules.WaterVariant.WATER_B:
			description = "Boss numbers add.\nFloor numbers multiply."
		GameRules.WaterVariant.WATER_C:
			description = "Boss numbers subtract.\nFloor numbers multiply."
		_:
			description = "Read each operation before touching it."

	if complication == GameRules.WaterComplication.REVERSED_CONTROLS:
		description += "\nLeft and right are reversed."
	elif complication == GameRules.WaterComplication.INVERTED_GRAVITY:
		description += "\nGravity is inverted."
	return description
