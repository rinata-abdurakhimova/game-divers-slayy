## FightStartCutscene.gd
## Bridge between CutsceneIntro and gameplay (4 seconds total):
##  0.0 – 0.5s  Slay Bot falls from top (Y:-200 → floor)
##  0.5s        Impact! Screen shake + dust cloud
##  0.5 – 1.5s  Boss 67 glides in from right
##  2.0 – 2.5s  Boss fires 3 projectiles
##  2.5 – 3.0s  Slay Bot dashes forward (afterimage trail)
##  3.2 – 4.0s  Fade to black → gameplay starts
class_name FightStartCutscene
extends CanvasLayer

signal cutscene_done

# Assigned directly by Main.gd before calling start()
var _boss_node:     Node2D = null
var _player_node:   Node2D = null
@export var floor_y: float = 580.0

var _black_rect:    ColorRect
var _dust_parts:    CPUParticles2D
var _trail_parts:   CPUParticles2D

var _real_timer:    float = 0.0
var _phase:         int   = 0
var _active:        bool  = false
var _boss_start_x:  float = 0.0
var _shake_timer:   float = 0.0
var _shots_fired:   int   = 0
var _shot_timer:    float = 0.0


func _ready() -> void:
	layer = 20
	process_mode = Node.PROCESS_MODE_ALWAYS

	_black_rect = ColorRect.new()
	_black_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_black_rect.color = Color(0, 0, 0, 1)
	_black_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_black_rect)

	# Dust cloud (on impact)
	_dust_parts = CPUParticles2D.new()
	_dust_parts.emitting              = false
	_dust_parts.one_shot              = true
	_dust_parts.amount                = 80
	_dust_parts.lifetime              = 1.2
	_dust_parts.randomness            = 1.0
	_dust_parts.emission_shape        = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	_dust_parts.emission_rect_extents = Vector2(50, 5)
	_dust_parts.direction             = Vector2(0, -1)
	_dust_parts.spread                = 70.0
	_dust_parts.gravity               = Vector2(0, 40)
	_dust_parts.initial_velocity_min  = 80.0
	_dust_parts.initial_velocity_max  = 200.0
	_dust_parts.color                 = Color(0.9, 0.72, 0.45, 0.6)
	_dust_parts.scale_amount_min      = 4.0
	_dust_parts.scale_amount_max      = 12.0
	add_child(_dust_parts)

	# Afterimage trail for dash
	_trail_parts = CPUParticles2D.new()
	_trail_parts.emitting             = false
	_trail_parts.amount               = 30
	_trail_parts.lifetime             = 0.3
	_trail_parts.randomness           = 0.2
	_trail_parts.direction            = Vector2(-1, 0)
	_trail_parts.spread               = 15.0
	_trail_parts.gravity              = Vector2.ZERO
	_trail_parts.initial_velocity_min = 5.0
	_trail_parts.initial_velocity_max = 20.0
	_trail_parts.color                = Color(1.0, 0.6, 0.9, 0.6)
	_trail_parts.scale_amount_min     = 3.0
	_trail_parts.scale_amount_max     = 8.0
	add_child(_trail_parts)

	hide()


func start(player: Node2D = null, boss: Node2D = null) -> void:
	show()
	_player_node = player
	_boss_node   = boss
	_boss_start_x = _boss_node.global_position.x if _boss_node else 600.0
	_black_rect.color = Color(0, 0, 0, 1)

	if _player_node:
		_player_node.global_position = Vector2(_player_node.global_position.x, -200)
	if _boss_node:
		_boss_start_x = _boss_node.global_position.x
		_boss_node.global_position.x = _boss_start_x + 700.0

	_real_timer = 0.0
	_phase      = 1
	_active     = true

	# Fade in from black
	var t := create_tween()
	t.tween_property(_black_rect, "color", Color(0, 0, 0, 0), 0.4)


func _process(delta: float) -> void:
	if not _active:
		return
	_real_timer += delta

	match _phase:
		1:  # Slay Bot falls (0.0 → 0.5s)
			if _player_node:
				var t: float = clampf(_real_timer / 0.5, 0.0, 1.0)
				_player_node.global_position.y = lerp(-200.0, floor_y, t)
			if _real_timer >= 0.5:
				_real_timer = 0.0
				_phase = 2
				# Impact!
				if _player_node:
					_dust_parts.position = _player_node.global_position + Vector2(0, 20)
					_dust_parts.emitting = true
				_shake_timer = 0.0

		2:  # Impact screen shake (0.3s) + Boss glides in (ends at 1.5s)
			_shake_timer += delta
			if _real_timer < 0.3:
				var sh: float = 5.0 * (1.0 - _real_timer / 0.3)
				offset = Vector2(sin(_shake_timer * 90.0) * sh, cos(_shake_timer * 70.0) * sh)
			else:
				offset = Vector2.ZERO

			# Boss glides in from right over 1s
			if _boss_node and _real_timer >= 0.0:
				var bt: float = clampf(_real_timer / 1.0, 0.0, 1.0)
				_boss_node.global_position.x = lerp(_boss_start_x + 700.0, _boss_start_x, bt)

			if _real_timer >= 1.5:
				_real_timer = 0.0
				_shots_fired = 0
				_shot_timer  = 0.0
				_phase = 3

		3:  # Wait until 2.0s mark, then fire 3 shots (0.5s between each)
			_shot_timer += delta
			if _shots_fired < 3 and _shot_timer >= 0.25 * float(_shots_fired + 1):
				_fire_shot()
				_shots_fired += 1
			if _real_timer >= 0.8:
				_real_timer = 0.0
				_phase = 4

		4:  # Slay Bot dashes forward (0.5s)
			if _player_node:
				var t: float = clampf(_real_timer / 0.5, 0.0, 1.0)
				_player_node.global_position.x += delta * 300.0 * (1.0 - t * 0.5)
				_trail_parts.position = _player_node.global_position
				_trail_parts.emitting = _real_timer < 0.5
			if _real_timer >= 0.7:
				_real_timer = 0.0
				_trail_parts.emitting = false
				_phase = 5

		5:  # Fade to black (0.8s) → signal done
			var a: float = clampf(_real_timer / 0.8, 0.0, 1.0)
			_black_rect.color = Color(0, 0, 0, a)
			if _real_timer >= 0.8:
				_active = false
				_black_rect.color = Color(0, 0, 0, 0)
				hide()
				cutscene_done.emit()


func _fire_shot() -> void:
	if not _boss_node:
		return
	# Spawn a simple visual projectile (Label with "×" moving left)
	var lbl := Label.new()
	lbl.text = "⚡"
	lbl.add_theme_font_size_override("font_size", 36)
	lbl.add_theme_color_override("font_color", Color(1, 0.9, 0.3, 1))
	lbl.global_position = _boss_node.global_position + Vector2(-30, randf_range(-40, 40))
	get_tree().current_scene.add_child(lbl)
	var pt := lbl.create_tween()
	pt.tween_property(lbl, "global_position",
		lbl.global_position + Vector2(-600, randf_range(-30, 30)), 1.0)
	pt.parallel().tween_property(lbl, "modulate:a", 0.0, 1.0)
	pt.finished.connect(lbl.queue_free)
