extends TextureRect

@export_file("*.png", "*.jpg", "*.jpeg", "*.webp") var source_path: String


func _ready() -> void:
	if source_path.is_empty():
		return

	var absolute_path: String = ProjectSettings.globalize_path(source_path)
	var image: Image = Image.load_from_file(absolute_path)
	if image == null or image.is_empty():
		push_warning("Unable to load UI backdrop: %s" % source_path)
		return
	texture = ImageTexture.create_from_image(image)
