extends Node

var _sounds: Dictionary[StringName, AudioStream] = {}
var _sfx_player: AudioStreamPlayer
var _previous_shields: int = GameRules.LEVEL_01_STARTING_SHIELDS


func _ready() -> void:
	_sfx_player = AudioStreamPlayer.new()
	_sfx_player.name = "SFXPlayer"
	add_child(_sfx_player)
	_register_placeholder_sounds()
	GameEvents.operand_collected.connect(_on_operand_collected)
	GameEvents.equation_submitted.connect(_on_equation_submitted)
	GameEvents.shield_changed.connect(_on_shield_changed)
	GameEvents.tide_started.connect(_on_tide_started)
	GameEvents.level_completed.connect(_on_level_completed)


func register_sound(sound_id: StringName, stream: AudioStream) -> void:
	if stream == null:
		return
	_sounds[sound_id] = stream


func play_sfx(sound_id: StringName) -> void:
	var stream: AudioStream = _sounds.get(sound_id) as AudioStream
	if stream == null:
		push_warning("AudioBus has no stream registered for '%s'." % sound_id)
		return

	_sfx_player.stream = stream
	_sfx_player.play()


func _register_placeholder_sounds() -> void:
	register_sound(GameRules.SFX_OPERAND_COLLECT, _make_tone(660.0, 0.07, 0.18))
	register_sound(GameRules.SFX_EQUATION_WRONG, _make_tone(180.0, 0.14, 0.16))
	register_sound(GameRules.SFX_SHIELD_BREAK, _make_tone(880.0, 0.11, 0.2))
	register_sound(GameRules.SFX_TIDE, _make_tone(330.0, 0.3, 0.16))
	register_sound(GameRules.SFX_LEVEL_WIN, _make_tone(990.0, 0.32, 0.18))


func _make_tone(frequency: float, duration: float, volume: float) -> AudioStreamWAV:
	const MIX_RATE: int = 22050
	var sample_count: int = maxi(1, int(duration * MIX_RATE))
	var bytes := PackedByteArray()
	bytes.resize(sample_count * 2)

	for sample_index: int in sample_count:
		var time: float = float(sample_index) / float(MIX_RATE)
		var fade: float = 1.0 - (float(sample_index) / float(sample_count))
		var sample: int = int(sin(TAU * frequency * time) * volume * fade * 32767.0)
		var unsigned_sample: int = sample & 0xFFFF
		bytes[sample_index * 2] = unsigned_sample & 0xFF
		bytes[sample_index * 2 + 1] = (unsigned_sample >> 8) & 0xFF

	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.stereo = false
	stream.data = bytes
	return stream


func _on_operand_collected(_value: int, _slot: int) -> void:
	play_sfx(GameRules.SFX_OPERAND_COLLECT)


func _on_equation_submitted(correct: bool) -> void:
	if not correct:
		play_sfx(GameRules.SFX_EQUATION_WRONG)


func _on_shield_changed(remaining: int) -> void:
	if remaining < _previous_shields:
		play_sfx(GameRules.SFX_SHIELD_BREAK)
	_previous_shields = remaining


func _on_tide_started() -> void:
	play_sfx(GameRules.SFX_TIDE)


func _on_level_completed(_level_id: StringName) -> void:
	play_sfx(GameRules.SFX_LEVEL_WIN)
