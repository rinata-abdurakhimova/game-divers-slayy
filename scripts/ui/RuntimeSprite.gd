extends Sprite2D

@export_file("*.png", "*.jpg", "*.jpeg", "*.webp", "*.svg") var source_path: String
@export var display_size: Vector2 = Vector2.ZERO


func _ready() -> void:
	if source_path.is_empty():
		return

	var image := Image.new()
	var absolute_path: String = ProjectSettings.globalize_path(source_path)
	var load_error: Error
	if source_path.get_extension().to_lower() == "svg":
		load_error = image.load_svg_from_string(FileAccess.get_file_as_string(absolute_path))
	else:
		load_error = image.load(absolute_path)

	if load_error != OK or image.is_empty():
		push_warning("Unable to load runtime sprite: %s" % source_path)
		return

	texture = ImageTexture.create_from_image(image)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if display_size.x > 0.0 and display_size.y > 0.0:
		scale = Vector2(
			display_size.x / float(image.get_width()),
			display_size.y / float(image.get_height())
		)
