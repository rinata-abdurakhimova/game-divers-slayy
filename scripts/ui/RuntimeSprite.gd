extends Sprite2D

@export var source_texture: Texture2D
@export var display_size: Vector2 = Vector2.ZERO


func _ready() -> void:
	if source_texture == null:
		return

	texture = source_texture
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var texture_size: Vector2 = source_texture.get_size()
	if display_size.x > 0.0 and display_size.y > 0.0:
		if texture_size.x <= 0.0 or texture_size.y <= 0.0:
			push_warning("Runtime sprite texture has no displayable size.")
			return
		scale = Vector2(
			display_size.x / texture_size.x,
			display_size.y / texture_size.y
		)
