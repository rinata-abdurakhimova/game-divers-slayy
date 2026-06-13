extends Node


func _ready() -> void:
	GameState.reset_level_01()
	GameEvents.run_started.emit(GameRules.LEVEL_01_ID)
