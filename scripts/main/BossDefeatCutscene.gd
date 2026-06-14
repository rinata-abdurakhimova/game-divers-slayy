## BossDefeatCutscene.gd
## Triggered when player hits exactly 67.
## Timeline (6 seconds total):
##  0.0 – 0.5s  Time slows to 0.2
##  0.5 – 1.5s  Slay Bot leaps toward Boss in slow-motion
##  1.5s        Strike — time freezes 0.15 real seconds (hit-stop)
##  1.65– 3.0s  Screen shake + Boss white-flash + green shockwave
##  3.0 – 4.5s  Boss shatters (CPUParticles2D)
##  4.5 – 6.0s  Screen fades to white → CutsceneOutro shown
class_name BossDefeatCutscene
extends CanvasLayer

signal cutscene_done

# Assigned directly by Main.gd before calling start()
var _boss_node:   Node2D = null
var _player_node: Node2D = null

# Visual nodes (all created in _ready to keep the scene minimal)
var _white_rect:     ColorRect
var _shockwave:      Sprite2D
var _shatter_parts:  CPUParticles2D

# Internal state
var _real_timer:      float  = 0.0
var _phase:           int    = 0   # 0=idle,1=slow,2=leap,3=strike,4=shake,5=shatter,6=fade
var _boss_start_pos:  Vector2
var _player_start_pos: Vector2
var _hit_stop_timer:  float  = 0.0
var _hit_stop_dur:    float  = 0.15
var _shake_timer:     float  = 0.0
var _active:          bool   = false
var _flash_timer:     float  = 0.0


func _ready() -> void:
	layer = 20
	process_mode = Node.PROCESS_MODE_ALWAYS

	# White full-screen overlay
	_white_rect = ColorRect.new()
	_white_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_white_rect.color = Color(1, 1, 1, 0)
	_white_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_white_rect)

	# Shockwave ring (Sprite2D scaled from 0→huge)
	_shockwave = Sprite2D.new()
	# Use a simple programmatic circle texture
	var img := Image.create(128, 128, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)
	for y in range(128):
		for x in range(128):
			var dist: float = Vector2(x - 64, y - 64).length()
			if dist > 56 and dist < 64:
				img.set_pixel(x, y, Color(0.2, 1.0, 0.5, 1.0))
	_shockwave.texture = ImageTexture.create_from_image(img)
	_shockwave.scale = Vector2.ZERO
	_shockwave.visible = false
	add_child(_shockwave)

	# Shatter particles
	_shatter_parts = CPUParticles2D.new()
	_shatter_parts.emitting       = false
	_shatter_parts.one_shot       = true
	_shatter_parts.amount         = 200
	_shatter_parts.lifetime       = 2.5
	_shatter_parts.randomness     = 1.0
	_shatter_parts.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	_shatter_parts.emission_sphere_radius = 30.0
	_shatter_parts.direction      = Vector2(0, -1)
	_shatter_parts.spread         = 180.0
	_shatter_parts.gravity        = Vector2(0, 300)
	_shatter_parts.initial_velocity_min = 200.0
	_shatter_parts.initial_velocity_max = 600.0
	_shatter_parts.color          = Color(1.0, 0.25, 0.25, 1.0)
	_shatter_parts.scale_amount_min = 3.0
	_shatter_parts.scale_amount_max = 10.0
	add_child(_shatter_parts)

	hide()


func start(player: Node2D = null, boss: Node2D = null) -> void:
	show()
	_player_node = player
	_boss_node   = boss
	_white_rect.color = Color(1, 1, 1, 0)
	_shockwave.visible = false
	if _boss_node:
		_boss_start_pos = _boss_node.global_position
	if _player_node:
		_player_start_pos = _player_node.global_position

	_real_timer = 0.0
	_phase      = 1
	_active     = true
	Engine.time_scale = 0.2


func _process(delta: float) -> void:
	if not _active:
		return

	# Use unscaled delta for cutscene timing
	var real_delta: float = delta / Engine.time_scale

	match _phase:
		1:  # Slow-mo starts, wait 0.5s
			_real_timer += real_delta
			if _real_timer >= 0.5:
				_real_timer = 0.0
				_phase = 2

		2:  # Slay Bot leaps toward Boss (1 second real)
			_real_timer += real_delta
			if _player_node and _boss_node:
				var t: float = clampf(_real_timer / 1.0, 0.0, 1.0)
				var target: Vector2 = _boss_start_pos + Vector2(0, 60)
				_player_node.global_position = _player_start_pos.lerp(target, t)
			if _real_timer >= 1.0:
				_real_timer = 0.0
				_phase = 3
				Engine.time_scale = 0.0  # FREEZE (hit-stop)

		3:  # Hit-stop (uses real process time, not game time)
			_hit_stop_timer += delta  # real seconds (time_scale=0)
			if _hit_stop_timer >= _hit_stop_dur:
				_hit_stop_timer = 0.0
				Engine.time_scale = 1.0
				_phase = 4
				# Trigger shockwave at boss position
				if _boss_node:
					_shockwave.position = _boss_node.global_position
					_shockwave.scale    = Vector2.ZERO
					_shockwave.visible  = true
					var sw_tween := create_tween()
					sw_tween.tween_property(_shockwave, "scale",
						Vector2(8, 8), 0.5).set_trans(Tween.TRANS_EXPO)
					sw_tween.parallel().tween_property(_shockwave, "modulate:a",
						0.0, 0.5)

		4:  # Screen shake + Boss white flash (1.35s)
			_real_timer    += real_delta
			_shake_timer   += real_delta
			_flash_timer   += real_delta

			# Shake camera (offset the canvas layer)
			if _real_timer < 1.35:
				var sh: float = 15.0 * (1.0 - _real_timer / 1.35)
				offset = Vector2(
					sin(_shake_timer * 80.0) * sh,
					cos(_shake_timer * 65.0) * sh
				)

			# Boss white flash every 0.1s
			if _boss_node and fmod(_flash_timer, 0.12) < 0.06:
				_boss_node.modulate = Color.WHITE
			elif _boss_node:
				_boss_node.modulate = Color(1, 0.25, 0.25, 1)

			if _real_timer >= 1.35:
				offset = Vector2.ZERO
				if _boss_node:
					_boss_node.modulate = Color.WHITE
				_real_timer = 0.0
				_flash_timer = 0.0
				_phase = 5
				# Shatter
				if _boss_node:
					_shatter_parts.position = _boss_node.global_position
					_shatter_parts.emitting = true
					_boss_node.hide()

		5:  # Shatter & wait 1.5s
			_real_timer += real_delta
			if _real_timer >= 1.5:
				_real_timer = 0.0
				_phase = 6

		6:  # Fade to white (1.5s)
			_real_timer += real_delta
			var a: float = clampf(_real_timer / 1.5, 0.0, 1.0)
			_white_rect.color = Color(1, 1, 1, a)
			if _real_timer >= 1.5:
				_active = false
				Engine.time_scale = 1.0
				_white_rect.color = Color(1, 1, 1, 0)
				hide()
				cutscene_done.emit()
