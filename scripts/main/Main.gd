extends Node

const BOSS_LEVEL_SCENE := "res://scenes/world/Boss67Level.tscn"

@onready var level_container:   Node2D  = %LevelContainer
@onready var hud:               Control = %HUD
@onready var tutorial_overlay:  Control = %TutorialOverlay
@onready var cutscene_intro:    Control = %CutsceneIntro
@onready var cutscene_outro:    Control = %CutsceneOutro
@onready var result_screen:     Control = %ResultScreen

# In-engine action cutscene controllers (CanvasLayer scripts, added in _ready)
var _fight_start_cs: Node = null   # FightStartCutscene
var _boss_defeat_cs:  Node = null  # BossDefeatCutscene

var _gameplay_started: bool = false
var _victory_cs_fired: bool = false


# ─────────────────────────────────────────────────────────────────────────────
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Hide everything until intro is done
	hud.hide()
	tutorial_overlay.hide()
	cutscene_outro.hide()
	result_screen.hide()
	cutscene_intro.show()

	# Create action-cutscene CanvasLayers (no scene file needed)
	_fight_start_cs = _make_cutscene_layer(
		preload("res://scripts/main/FightStartCutscene.gd"), 110)
	_boss_defeat_cs  = _make_cutscene_layer(
		preload("res://scripts/main/BossDefeatCutscene.gd"), 115)

	# Wire signals
	GameState.reset_boss_67_run()
	GameEvents.cutscene_finished.connect(_on_intro_finished)
	GameEvents.game_over.connect(_on_game_over)

	if cutscene_outro.has_signal(&"outro_completed"):
		cutscene_outro.outro_completed.connect(_on_outro_completed)

	_fight_start_cs.cutscene_done.connect(_on_fight_start_done)
	_boss_defeat_cs.cutscene_done.connect(_on_boss_defeat_done)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause") and _gameplay_started \
			and not GameState.outcome_locked:
		get_tree().paused = not get_tree().paused
		hud.set_paused(get_tree().paused)
		get_viewport().set_input_as_handled()


func _exit_tree() -> void:
	Engine.time_scale = 1.0
	if get_tree() != null:
		get_tree().paused = false


# ── Helpers ───────────────────────────────────────────────────────────────────
func _make_cutscene_layer(script: GDScript, layer_index: int) -> Node:
	var node := CanvasLayer.new()
	node.layer = layer_index
	node.set_script(script)
	node.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(node)
	return node


func _get_level() -> Node2D:
	# Returns the Boss67Level node if it's loaded inside level_container
	for child in level_container.get_children():
		if child.name == "Boss67Level" or child.get_class() == "Node2D":
			return child as Node2D
	return null


# ── Flow ──────────────────────────────────────────────────────────────────────

# Called when CutsceneIntro ends (player presses СТАРТ)
func _on_intro_finished() -> void:
	if _gameplay_started:
		return
	_gameplay_started = true

	# Load the game level
	GameState.reset_boss_67_run()
	var packed := load(BOSS_LEVEL_SCENE) as PackedScene
	if packed == null:
		push_error("Cannot load Boss67Level scene")
		_on_fight_start_done()   # skip cutscene, go straight to HUD
		return
	var level := packed.instantiate() as Node2D
	level_container.add_child(level)

	# Point action cutscenes at the real nodes
	var player_node := level.get_node_or_null("Actors/Player") as Node2D
	var boss_node   := level.get_node_or_null("Actors/Boss67") as Node2D

	if player_node and boss_node:
		_fight_start_cs.start(player_node, boss_node)
	else:
		push_warning("FightStartCutscene: could not find Player or Boss67 node, skipping.")
		_on_fight_start_done()


# Fight-start cutscene finished → show HUD and enable gameplay
func _on_fight_start_done() -> void:
	hud.show()
	tutorial_overlay.show()
	GameEvents.run_started.emit()


# game_over signal: won=true means player hit exactly 67
func _on_game_over(won: bool, _reason: StringName, _score_cents: int) -> void:
	if won and not _victory_cs_fired:
		_victory_cs_fired = true
		hud.hide()
		tutorial_overlay.hide()
		var level := _get_level()
		var player_node := level.get_node_or_null("Actors/Player") as Node2D if level else null
		var boss_node   := level.get_node_or_null("Actors/Boss67") as Node2D if level else null
		_boss_defeat_cs.start(player_node, boss_node)
	elif not won:
		result_screen.show()


# Victory cutscene done → fade into Outro slides
func _on_boss_defeat_done() -> void:
	cutscene_outro.show()


# Outro slides done → restart
func _on_outro_completed() -> void:
	Engine.time_scale = 1.0
	get_tree().paused  = false
	GameEvents.restart_requested.emit()
