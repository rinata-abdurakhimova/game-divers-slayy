extends TextureRect

@export var source_texture: Texture2D


func _ready() -> void:
	if source_texture == null:
		return
	texture = source_texture
