extends Node

const WORLD_SCENE_PATH: String = "res://scenes/world/Boss67Level.tscn"
const FALLBACK_SCENE_PATH: String = "res://scenes/main/Boss67FallbackLevel.tscn"

@onready var level_container: Node2D = %LevelContainer
@onready var hud: Control = %HUD
@onready var tutorial_overlay: Control = %TutorialOverlay
@onready var cutscene_intro: Control = %CutsceneIntro

var _gameplay_started: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	GameState.reset_boss_67_run()
	GameEvents.cutscene_finished.connect(_on_cutscene_finished)
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
	_instantiate_level()
	hud.show()
	tutorial_overlay.show()
	GameEvents.run_started.emit()


func _instantiate_level() -> void:
	var scene_path: String = WORLD_SCENE_PATH if ResourceLoader.exists(WORLD_SCENE_PATH) \
		else FALLBACK_SCENE_PATH
	var level_scene: PackedScene = load(scene_path) as PackedScene
	if level_scene == null:
		push_error("Unable to load Boss 67 level scene: %s" % scene_path)
		return
	level_container.add_child(level_scene.instantiate())
