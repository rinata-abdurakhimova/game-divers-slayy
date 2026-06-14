extends Node

@onready var level_container: Node2D = %LevelContainer
@onready var boss_67_level: Node2D = %Boss67Level
@onready var hud: Control = %HUD
@onready var tutorial_overlay: Control = %TutorialOverlay
@onready var cutscene_intro: Control = %CutsceneIntro

var _gameplay_started: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	GameState.reset_boss_67_run()
	GameEvents.cutscene_finished.connect(_on_cutscene_finished)
	if cutscene_intro.has_signal(&"intro_finished"):
		cutscene_intro.connect(&"intro_finished", _on_cutscene_finished)
	boss_67_level.hide()
	boss_67_level.process_mode = Node.PROCESS_MODE_DISABLED
	hud.hide()
	tutorial_overlay.hide()
	cutscene_intro.show()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause") and _gameplay_started and not GameState.outcome_locked:
		get_tree().paused = not get_tree().paused
		hud.set_paused(get_tree().paused)
		get_viewport().set_input_as_handled()


func _exit_tree() -> void:
	if get_tree() != null:
		get_tree().paused = false


func _on_cutscene_finished() -> void:
	if _gameplay_started:
		return
	_gameplay_started = true
	# Web pages can retain the canvas briefly across reloads. Reset at the actual
	# gameplay boundary so no terminal run state can reach the first frame.
	GameState.reset_boss_67_run()
	boss_67_level.process_mode = Node.PROCESS_MODE_INHERIT
	boss_67_level.show()
	hud.show()
	tutorial_overlay.show()
	GameEvents.run_started.emit()
