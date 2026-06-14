class_name CutsceneOutro
extends Control

signal outro_completed

const SLIDES: Array[Dictionary] = [
	{
		"image":    "res://assets/cutscenes/outro_1.png",
		"audio":    "res://assets/audio/voiceovers/outro_1.mp3",
		"text":     "Рівняння закрито. Баланс числа 67 досягнуто. Аномалія втрачає контроль над реальністю.",
		"zoom_from": 1.0, "zoom_to": 1.12, "pan": Vector2(0.0, 0.0),
		"duration":  8.0, "shader": "neon", "particles": "",
	},
	{
		"image":    "res://assets/cutscenes/outro_2.png",
		"audio":    "res://assets/audio/voiceovers/outro_2.mp3.mp3",
		"text":     "Математичний шторм вщухає. Пісок і вода знову підкоряються законам природи. Ти повернув стабільність у цей сектор.",
		"zoom_from": 1.05, "zoom_to": 1.05, "pan": Vector2(0.0, 28.0),
		"duration":  9.0, "shader": "", "particles": "both",
	},
	{
		"image":    "res://assets/cutscenes/outro_3.png",
		"audio":    "res://assets/audio/voiceovers/outro_3.mp3.mp3",
		"text":     "Ти довів, що найгірший хаос завжди має свій розв'язок. Дякуємо тобі, Слей Дайвере. Але у світі залишається ще багато нестабільних зон... Відпочинь. Скоро нове занурення.",
		"zoom_from": 1.15, "zoom_to": 1.0, "pan": Vector2(0.0, 0.0),
		"duration": 11.0, "shader": "", "particles": "",
	},
]

@onready var _image_rect:     TextureRect    = %ImageRect
@onready var _sparkle:        CPUParticles2D = %SparkleParticles
@onready var _gold:           CPUParticles2D = %GoldParticles
@onready var _fade_rect:      ColorRect      = %FadeRect
@onready var _subtitle:       RichTextLabel  = %SubtitleLabel
@onready var _prompt:         Label          = %PromptLabel
@onready var _credits_screen: ColorRect      = %CreditsScreen
@onready var _continue_btn:   Button         = %ContinueButton

const NEON_SHADER := preload("res://shaders/neon_scanline.gdshader")
const CHARS_PER_SEC: float = 40.0

var _slide_index:   int   = -1
var _slide_timer:   float = 0.0
var _typing_chars:  float = 0.0
var _is_typing:     bool  = false
var _slide_done:    bool  = false
var _finished:      bool  = false
var _started:       bool  = false
var _transitioning: bool  = false   # ← prevents double-advance during fade
var _audio:         AudioStreamPlayer
var _neon_mat:      ShaderMaterial
var _current_tween: Tween


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_continue_btn.pressed.connect(_finish_outro)
	_fade_rect.color = Color(0, 0, 0, 1)
	_credits_screen.hide()
	_prompt.hide()

	_audio = AudioStreamPlayer.new()
	add_child(_audio)

	_neon_mat = ShaderMaterial.new()
	_neon_mat.shader = NEON_SHADER
	_neon_mat.set_shader_parameter("intensity", 0.7)

	# Do NOT auto-start — wait until show() is called
	visibility_changed.connect(_on_visibility_changed)


func _on_visibility_changed() -> void:
	if visible and not _started:
		_started = true
		_next_slide()


func _process(delta: float) -> void:
	if not _started or _finished or _transitioning or _slide_index < 0 or _slide_index >= SLIDES.size():
		return
	_slide_timer += delta

	# Typewriter effect
	if _is_typing:
		_typing_chars += delta * CHARS_PER_SEC
		_subtitle.visible_characters = int(_typing_chars)
		if _subtitle.visible_characters >= _subtitle.get_total_character_count():
			_is_typing = false
			_prompt.show()

	# Auto-advance after audio ends (with 2s minimum to let audio start)
	if not _slide_done and _slide_timer > 2.0 and not _audio.playing:
		_slide_done = true
		_advance()


func _unhandled_input(event: InputEvent) -> void:
	if not visible or _finished or _credits_screen.visible or _transitioning:
		return
	var mb := event as InputEventMouseButton
	var pressed: bool = event.is_action_pressed(&"ui_accept") \
		or event.is_action_pressed(&"action") \
		or (mb != null and mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT)
	if not pressed:
		return
	get_viewport().set_input_as_handled()
	if _is_typing:
		# First click: reveal all text immediately
		_subtitle.visible_characters = -1
		_is_typing = false
		_prompt.show()
	elif not _slide_done:
		# Second click: skip to next slide
		_slide_done = true
		_advance()


func _next_slide() -> void:
	_transitioning = false
	_slide_index += 1

	if _slide_index >= SLIDES.size():
		_show_credits()
		return

	var slide: Dictionary = SLIDES[_slide_index]
	_slide_done   = false
	_slide_timer  = 0.0
	_typing_chars = 0.0
	_is_typing    = false
	_prompt.hide()

	# Load image — set pivot to viewport center (no await needed)
	var tex: Texture2D = load(slide["image"]) as Texture2D
	_image_rect.texture = tex
	var vp_size: Vector2 = get_viewport().get_visible_rect().size
	_image_rect.pivot_offset = vp_size / 2.0

	# Apply shader
	match slide.get("shader", ""):
		"neon":
			_image_rect.material = _neon_mat
		_:
			_image_rect.material = null

	# Particles
	var parts: String = slide.get("particles", "")
	_sparkle.emitting = parts in ["both", "sparkle"]
	_gold.emitting    = parts in ["both", "gold"]

	# Set subtitle text and start typewriter
	_subtitle.text = slide.get("text", "")
	_subtitle.visible_characters = 0
	_is_typing = true

	# Play audio if available
	var audio_path: String = slide.get("audio", "")
	if ResourceLoader.exists(audio_path):
		_audio.stream = load(audio_path)
		_audio.play()
	else:
		# No audio — use duration as fallback timer
		_slide_timer = -slide.get("duration", 6.0) + 2.0

	# Ken Burns tween
	var zoom_from: float   = slide.get("zoom_from", 1.0)
	var zoom_to:   float   = slide.get("zoom_to",   1.0)
	var pan:       Vector2 = slide.get("pan", Vector2.ZERO)
	var dur:       float   = slide.get("duration", 8.0)

	if _current_tween:
		_current_tween.kill()
	_current_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_IDLE)
	_image_rect.scale    = Vector2(zoom_from, zoom_from)
	_image_rect.position = Vector2.ZERO
	_current_tween.tween_property(_image_rect, "scale",
		Vector2(zoom_to, zoom_to), dur).set_trans(Tween.TRANS_SINE)
	_current_tween.parallel().tween_property(_image_rect, "position",
		pan, dur).set_trans(Tween.TRANS_SINE)

	_fade_in(0.4)


func _advance() -> void:
	if _transitioning:
		return
	_transitioning = true
	if _current_tween:
		_current_tween.kill()
	_audio.stop()
	_sparkle.emitting = false
	_gold.emitting    = false
	_fade_out(0.4, _next_slide)


func _fade_in(dur: float) -> void:
	var t := create_tween()
	t.tween_property(_fade_rect, "color", Color(0, 0, 0, 0), dur)


func _fade_out(dur: float, callback: Callable) -> void:
	var t := create_tween()
	t.tween_property(_fade_rect, "color", Color(0, 0, 0, 1), dur)
	t.finished.connect(callback)


func _show_credits() -> void:
	_transitioning = false
	_sparkle.emitting = false
	_gold.emitting    = false
	_subtitle.hide()
	_prompt.hide()
	_credits_screen.show()
	_credits_screen.modulate.a = 0.0
	var t := create_tween()
	t.tween_property(_credits_screen, "modulate:a", 1.0, 1.0)
	t.finished.connect(func(): _continue_btn.grab_focus())
	_fade_in(1.0)


func _finish_outro() -> void:
	if _finished:
		return
	_finished = true
	_audio.stop()
	_fade_out(0.5, func():
		hide()
		outro_completed.emit()
	)
