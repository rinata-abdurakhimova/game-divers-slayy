extends Control

const MAX_RECENT_OPERATIONS: int = 4

@onready var score_label: Label = %ScoreLabel
@onready var target_label: Label = %TargetLabel
@onready var phase_label: Label = %PhaseLabel
@onready var operations_label: Label = %OperationsLabel
@onready var water_panel: Control = %WaterPanel
@onready var water_timer_label: Label = %WaterTimerLabel
@onready var water_rule_label: Label = %WaterRuleLabel
@onready var powerup_panel: Control = %PowerupPanel
@onready var powerup_label: Label = %PowerupLabel
@onready var state_label: Label = %StateLabel
@onready var pause_panel: Control = %PausePanel

# The parent PanelContainer for Score and Target labels
@onready var score_panel: Control = %ScoreLabel.get_parent().get_parent()

var _recent_operations: Array[String] = []
var _powerup_seconds: Dictionary[StringName, float] = {}
var _score_visibility_timer: float = 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	GameEvents.run_started.connect(_on_run_started)
	GameEvents.score_changed.connect(_on_score_changed)
	GameEvents.score_operation_applied.connect(_on_score_operation_applied)
	GameEvents.distance_changed.connect(_on_distance_changed)
	GameEvents.boss_phase_changed.connect(_on_boss_phase_changed)
	GameEvents.water_started.connect(_on_water_started)
	GameEvents.water_timer_changed.connect(_on_water_timer_changed)
	GameEvents.water_finished.connect(_on_water_finished)
	GameEvents.powerup_started.connect(_on_powerup_started)
	GameEvents.powerup_finished.connect(_on_powerup_finished)
	GameEvents.game_over.connect(_on_game_over)
	_apply_snapshot(GameState.get_run_snapshot())


func _process(delta: float) -> void:
	if not get_tree().paused:
		if _score_visibility_timer > 0.0:
			_score_visibility_timer -= delta
			if _score_visibility_timer <= 0.0:
				score_panel.hide()

	if _powerup_seconds.is_empty() or get_tree().paused:
		return
	for kind: StringName in _powerup_seconds:
		_powerup_seconds[kind] = maxf(0.0, _powerup_seconds[kind] - delta)
	_refresh_powerup_text()


func set_paused(paused: bool) -> void:
	pause_panel.visible = paused


func _on_run_started() -> void:
	_recent_operations.clear()
	_powerup_seconds.clear()
	_score_visibility_timer = 0.0
	score_panel.hide()
	operations_label.text = "RECENT\n--"
	state_label.text = "REACH EXACTLY 67"
	pause_panel.hide()
	_apply_snapshot(GameState.get_run_snapshot())


func _on_score_changed(_score_cents: int, _display: String) -> void:
	score_label.text = "SCORE  %s" % _format_score_ui(_score_cents)
	_score_visibility_timer = 3.0
	score_panel.show()


func _on_score_operation_applied(
	operation: StringName,
	value_cents: int,
	source: StringName
) -> void:
	var source_text: String = str(source).replace("_", " ").to_upper()
	_recent_operations.push_front("%s  %s" % [
		_operation_label_ui(operation, value_cents),
		source_text,
	])
	if _recent_operations.size() > MAX_RECENT_OPERATIONS:
		_recent_operations.resize(MAX_RECENT_OPERATIONS)
	operations_label.text = "RECENT\n%s" % "\n".join(_recent_operations)


func _on_distance_changed(blocks: int) -> void:
	if GameState.water_variant != GameRules.WaterVariant.NONE:
		phase_label.text = "WATER  |  %d BLOCKS" % blocks
	else:
		phase_label.text = "LAND  |  %d BLOCKS" % blocks


func _on_boss_phase_changed(new_phase: GameRules.BossPhase) -> void:
	match new_phase:
		GameRules.BossPhase.HIDDEN:
			state_label.text = "BOSS 67 IS AHEAD"
		GameRules.BossPhase.LAND_WHITE:
			state_label.text = "WHITE NUMBERS HIT BLOCKS"
			_score_visibility_timer = 4.0
			score_panel.show()
		GameRules.BossPhase.LAND_PURPLE:
			state_label.text = "PURPLE NUMBERS PASS THROUGH BLOCKS"
		GameRules.BossPhase.WATER:
			state_label.text = "WATER RULE ACTIVE"
		GameRules.BossPhase.DEFEATED:
			state_label.text = "EXACTLY 67"


func _on_water_started(
	variant: GameRules.WaterVariant,
	complication: GameRules.WaterComplication,
	seconds: float
) -> void:
	water_panel.show()
	phase_label.text = "WATER  |  %d BLOCKS" % GameState.distance_blocks
	water_rule_label.text = _water_rule_text(variant, complication)
	_on_water_timer_changed(seconds)


func _on_water_timer_changed(seconds_left: float) -> void:
	water_timer_label.text = "WATER  %.1fs" % seconds_left


func _on_water_finished() -> void:
	water_panel.hide()
	phase_label.text = "LAND  |  %d BLOCKS" % GameState.distance_blocks


func _on_powerup_started(kind: StringName, seconds: float) -> void:
	_powerup_seconds[kind] = seconds
	_refresh_powerup_text()


func _on_powerup_finished(kind: StringName) -> void:
	_powerup_seconds.erase(kind)
	_refresh_powerup_text()


func _on_game_over(won: bool, _reason: StringName, _score_cents: int) -> void:
	state_label.text = "SUCCESS: EXACT 67" if won else "FAILED: SCORE IS 0"


func _apply_snapshot(snapshot: Dictionary) -> void:
	score_label.text = "SCORE  %s" % _format_score_ui(
		int(snapshot.get("score_cents", GameRules.BOSS_67_START_SCORE_CENTS))
	)
	target_label.text = "TARGET  %s" % snapshot.get("target_display", "67")
	_on_distance_changed(int(snapshot.get("distance_blocks", 0)))
	var snapshot_water: GameRules.WaterVariant = snapshot.get(
		"water_variant",
		GameRules.WaterVariant.NONE
	)
	water_panel.visible = snapshot_water != GameRules.WaterVariant.NONE
	powerup_panel.hide()


func _refresh_powerup_text() -> void:
	if _powerup_seconds.is_empty():
		powerup_panel.hide()
		return
	var lines: Array[String] = []
	for kind: StringName in _powerup_seconds:
		lines.append("%s  %.1fs" % [str(kind).replace("_", " ").to_upper(), _powerup_seconds[kind]])
	powerup_label.text = "\n".join(lines)
	powerup_panel.show()


func _water_rule_text(
	variant: GameRules.WaterVariant,
	complication: GameRules.WaterComplication
) -> String:
	var rule_text: String = "A: BOSS MULTIPLIES" if variant == GameRules.WaterVariant.WATER_A \
		else "B: FLOOR MULTIPLIES" if variant == GameRules.WaterVariant.WATER_B \
		else "C: BOSS SUBTRACTS"
	if complication == GameRules.WaterComplication.REVERSED_CONTROLS:
		rule_text += "  |  CONTROLS REVERSED"
	elif complication == GameRules.WaterComplication.INVERTED_GRAVITY:
		rule_text += "  |  GRAVITY INVERTED"
	return rule_text


func _operation_label_ui(operation: StringName, value_cents: int) -> String:
	var prefix: String = "?"
	if operation == GameRules.SCORE_OPERATION_ADD:
		prefix = "+"
	elif operation == GameRules.SCORE_OPERATION_SUBTRACT:
		prefix = "-"
	elif operation == GameRules.SCORE_OPERATION_MULTIPLY:
		prefix = "x"
	return "%s%s" % [prefix, _format_score_ui(value_cents)]


func _format_score_ui(value_cents: int) -> String:
	var sign_prefix: String = "-" if value_cents < 0 else ""
	var absolute_value: int = absi(value_cents)
	return "%s%d.%02d" % [sign_prefix, int(absolute_value / 100), absolute_value % 100]
