extends Node

const SFX_SCORE: StringName = &"score"
const SFX_WATER: StringName = &"water"
const SFX_POWERUP: StringName = &"powerup"
const SFX_WIN: StringName = &"win"
const SFX_FAIL: StringName = &"fail"

var _sounds: Dictionary[StringName, AudioStream] = {}
var _sfx_player: AudioStreamPlayer


func _ready() -> void:
	_sfx_player = AudioStreamPlayer.new()
	_sfx_player.name = "SFXPlayer"
	add_child(_sfx_player)
	_register_placeholder_sounds()
	GameEvents.score_operation_applied.connect(_on_score_operation_applied)
	GameEvents.water_started.connect(_on_water_started)
	GameEvents.powerup_started.connect(_on_powerup_started)
	GameEvents.game_over.connect(_on_game_over)


func register_sound(sound_id: StringName, stream: AudioStream) -> void:
	if stream != null:
		_sounds[sound_id] = stream


func play_sfx(sound_id: StringName) -> void:
	var stream: AudioStream = _sounds.get(sound_id) as AudioStream
	if stream == null:
		return
	_sfx_player.stream = stream
	_sfx_player.play()


func _register_placeholder_sounds() -> void:
	register_sound(SFX_SCORE, _make_tone(660.0, 0.07, 0.18))
	register_sound(SFX_WATER, _make_tone(330.0, 0.30, 0.16))
	register_sound(SFX_POWERUP, _make_tone(820.0, 0.12, 0.18))
	register_sound(SFX_WIN, _make_tone(990.0, 0.32, 0.18))
	register_sound(SFX_FAIL, _make_tone(170.0, 0.28, 0.16))


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


func _on_score_operation_applied(
	_operation: StringName,
	_value_cents: int,
	_source: StringName
) -> void:
	play_sfx(SFX_SCORE)


func _on_water_started(
	_variant: GameRules.WaterVariant,
	_complication: GameRules.WaterComplication,
	_seconds: float
) -> void:
	play_sfx(SFX_WATER)


func _on_powerup_started(_kind: StringName, _seconds: float) -> void:
	play_sfx(SFX_POWERUP)


func _on_game_over(won: bool, _reason: StringName, _score_cents: int) -> void:
	play_sfx(SFX_WIN if won else SFX_FAIL)
