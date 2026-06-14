class_name CutsceneIntro
extends Control

const SLIDES: Array[Dictionary] = [
	{
		"image":    "res://assets/cutscenes/intro_1.png",
		"audio":    "res://assets/audio/voiceovers/intro_1.mp3",
		"text":     "Наш світ розколовся. Аномалія «Бос 67» переписує константи реальності, зводячи все до абсолютного нуля. Звичайна зброя проти неї марна.",
		"zoom_from": 1.0, "zoom_to": 1.1, "pan": Vector2(18.0, -12.0),
		"duration":  9.0, "shader": "heat", "particles": "dust",
	},
	{
		"image":    "res://assets/cutscenes/intro_2.png",
		"audio":    "res://assets/audio/voiceovers/intro_2.mp3",
		"text":     "Єдиний спосіб вижити — пірнути в математичний хаос. Уникай нуля і досягни системного резонансу. Нам потрібне одне ідеальне число — 67.",
		"zoom_from": 1.05, "zoom_to": 1.05, "pan": Vector2(36.0, 0.0),
		"duration":  8.0, "shader": "glitch", "particles": "",
		"glitch_at": 3.0,
	},
	{
		"image":    "res://assets/cutscenes/intro_3.png",
		"audio":    "res://assets/audio/voiceovers/intro_3.mp3",
		"text":     "Твій вихід, Слей Дайвере. Пірнай у бурю. Збери ідеальне рівняння... або будь стертим назавжди!",
		"zoom_from": 1.0, "zoom_to": 1.2, "pan": Vector2(-8.0, 16.0),
		"duration":  7.0, "shader": "", "particles": "",
		"shake_at": 5.5,
	},
]

@onready var _image_rect:     TextureRect    = %ImageRect
@onready var _dust_particles: CPUParticles2D = %DustParticles
@onready var _fade_rect:      ColorRect      = %FadeRect
@onready var _subtitle:       RichTextLabel  = %SubtitleLabel
@onready var _prompt:         Label          = %PromptLabel
@onready var _title_screen:   ColorRect      = %TitleScreen
@onready var _start_button:   Button         = %StartButton

const HEAT_SHADER   := preload("res://shaders/heat_distortion.gdshader")
const GLITCH_SHADER := preload("res://shaders/glitch.gdshader")
const CHARS_PER_SEC: float = 40.0

var _slide_index:    int   = -1
var _slide_timer:    float = 0.0
var _typing_chars:   float = 0.0
var _is_typing:      bool  = false
var _slide_done:     bool  = false
var _finished:       bool  = false
var _transitioning:  bool  = false   # ← prevents double-advance during fade
var _audio:          AudioStreamPlayer
var _heat_mat:       ShaderMaterial
var _glitch_mat:     ShaderMaterial
var _current_tween:  Tween
var _glitch_tween:   Tween


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	_audio = AudioStreamPlayer.new()
	add_child(_audio)

	_heat_mat = ShaderMaterial.new()
	_heat_mat.shader = HEAT_SHADER

	_glitch_mat = ShaderMaterial.new()
	_glitch_mat.shader = GLITCH_SHADER
	_glitch_mat.set_shader_parameter("intensity", 0.0)

	_start_button.pressed.connect(finish_intro)
	_fade_rect.color = Color(0, 0, 0, 1.0)
	_title_screen.hide()
	_prompt.hide()
	_next_slide()


func _process(delta: float) -> void:
	if _finished or _transitioning or _slide_index < 0 or _slide_index >= SLIDES.size():
		return
	_slide_timer += delta

	# Typewriter effect
	if _is_typing:
		_typing_chars += delta * CHARS_PER_SEC
		_subtitle.visible_characters = int(_typing_chars)
		if _subtitle.visible_characters >= _subtitle.get_total_character_count():
			_is_typing = false
			_prompt.show()

	var slide: Dictionary = SLIDES[_slide_index]

	# Trigger glitch on slide 2
	if slide.get("shader", "") == "glitch" and _glitch_tween == null:
		if _slide_timer >= slide.get("glitch_at", 9999.0):
			_trigger_glitch()

	# Trigger shake on last slide (shake_at)
	if slide.get("shake_at", 9999.0) <= _slide_timer and not _slide_done:
		_slide_done = true
		_trigger_shake()
		return

	# Auto-advance after audio ends (with 2s minimum to let audio start)
	if not _slide_done and _slide_timer > 2.0 and not _audio.playing:
		_slide_done = true
		_advance()


func _unhandled_input(event: InputEvent) -> void:
	if _finished or _title_screen.visible or _transitioning:
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
		_show_title_screen()
		return

	var slide: Dictionary = SLIDES[_slide_index]
	_slide_done   = false
	_slide_timer  = 0.0
	_typing_chars = 0.0
	_glitch_tween = null
	_is_typing    = false
	_prompt.hide()

	# Load image — set pivot to viewport center (no await needed)
	var tex: Texture2D = load(slide["image"]) as Texture2D
	_image_rect.texture = tex
	var vp_size: Vector2 = get_viewport().get_visible_rect().size
	_image_rect.pivot_offset = vp_size / 2.0

	# Apply shader
	match slide.get("shader", ""):
		"heat":
			_image_rect.material = _heat_mat
		"glitch":
			_glitch_mat.set_shader_parameter("intensity", 0.0)
			_image_rect.material = _glitch_mat
		_:
			_image_rect.material = null

	_dust_particles.emitting = (slide.get("particles", "") == "dust")

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

	_fade_in(0.45)


func _advance() -> void:
	if _transitioning:
		return
	_transitioning = true
	if _current_tween:
		_current_tween.kill()
	_audio.stop()
	_fade_out(0.4, _next_slide)


func _trigger_glitch() -> void:
	_glitch_tween = create_tween()
	_glitch_tween.tween_method(
		func(v: float): _glitch_mat.set_shader_parameter("intensity", v), 0.0, 1.0, 0.2)
	_glitch_tween.tween_method(
		func(v: float): _glitch_mat.set_shader_parameter("intensity", v), 1.0, 0.0, 0.55)


func _trigger_shake() -> void:
	var original := _image_rect.position
	var shake_tw := create_tween()
	shake_tw.tween_method(
		func(t: float): _image_rect.position = original + Vector2(
			sin(t * 80.0) * 7.0, cos(t * 60.0) * 5.0),
		0.0, 1.0, 0.5)
	shake_tw.tween_property(_image_rect, "position", original, 0.1)
	shake_tw.finished.connect(_advance)


func _fade_in(dur: float) -> void:
	var t := create_tween()
	t.tween_property(_fade_rect, "color", Color(0, 0, 0, 0), dur)


func _fade_out(dur: float, callback: Callable) -> void:
	var t := create_tween()
	t.tween_property(_fade_rect, "color", Color(0, 0, 0, 1), dur)
	t.finished.connect(callback)


func _show_title_screen() -> void:
	_transitioning = false
	_dust_particles.emitting = false
	_subtitle.hide()
	_prompt.hide()
	_title_screen.show()
	_title_screen.modulate.a = 0.0
	var t := create_tween()
	t.tween_property(_title_screen, "modulate:a", 1.0, 0.8)
	t.finished.connect(func(): _start_button.grab_focus())
	_fade_in(0.8)


func finish_intro() -> void:
	if _finished:
		return
	_finished = true
	_audio.stop()
	_fade_out(0.5, func():
		hide()
		GameEvents.cutscene_finished.emit()
	)
