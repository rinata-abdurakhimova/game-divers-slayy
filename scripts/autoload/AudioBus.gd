extends Node

const SFX_SCORE: StringName = &"score"
const SFX_WATER: StringName = &"water"
const SFX_POWERUP: StringName = &"powerup"
const SFX_WIN: StringName = &"win"
const SFX_FAIL: StringName = &"fail"

const MUSIC_MAIN_PATH: String = "res://assets/audio/music/main_music.mp3"
const SFX_CATCH_UNDERWATER_PATH: String = "res://assets/audio/music/catch_under_water.mp3"
const SFX_WIN_PATH: String = "res://assets/audio/music/winning sound.mp3"

const MUSIC_VOLUME_DB: float = -12.0
const CATCH_UNDERWATER_VOLUME_DB: float = -6.0
const CATCH_UNDERWATER_DURATION_SECONDS: float = 0.35
const WIN_SOUND_VOLUME_DB: float = -6.0

var _sounds: Dictionary[StringName, AudioStream] = {}
var _sfx_player: AudioStreamPlayer
var _music_player: AudioStreamPlayer
var _water_catch_player: AudioStreamPlayer
var _win_player: AudioStreamPlayer


func _ready() -> void:
	# Keep all audio playing through pause / cutscene time-scale changes
	# (cutscene controllers set get_tree().paused / Engine.time_scale).
	process_mode = Node.PROCESS_MODE_ALWAYS

	_sfx_player = AudioStreamPlayer.new()
	_sfx_player.name = "SFXPlayer"
	add_child(_sfx_player)
	_register_placeholder_sounds()
	_setup_music_player()
	_setup_one_shot_players()
	GameEvents.score_operation_applied.connect(_on_score_operation_applied)
	GameEvents.water_started.connect(_on_water_started)
	GameEvents.powerup_started.connect(_on_powerup_started)
	GameEvents.game_over.connect(_on_game_over)
	# Don't play the main music during the intro cutscene — start it once
	# the player finishes the intro and gameplay begins.
	GameEvents.cutscene_finished.connect(_on_cutscene_finished)


func _setup_music_player() -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.name = "MusicPlayer"
	_music_player.volume_db = MUSIC_VOLUME_DB
	add_child(_music_player)

	if not ResourceLoader.exists(MUSIC_MAIN_PATH):
		return
	var stream: AudioStream = load(MUSIC_MAIN_PATH)
	if stream is AudioStreamMP3:
		(stream as AudioStreamMP3).loop = true
	_music_player.stream = stream


func _on_cutscene_finished() -> void:
	if _music_player.stream != null:
		_music_player.play()


func _setup_one_shot_players() -> void:
	_water_catch_player = AudioStreamPlayer.new()
	_water_catch_player.name = "WaterCatchPlayer"
	_water_catch_player.volume_db = CATCH_UNDERWATER_VOLUME_DB
	add_child(_water_catch_player)
	if ResourceLoader.exists(SFX_CATCH_UNDERWATER_PATH):
		_water_catch_player.stream = load(SFX_CATCH_UNDERWATER_PATH)

	_win_player = AudioStreamPlayer.new()
	_win_player.name = "WinPlayer"
	_win_player.volume_db = WIN_SOUND_VOLUME_DB
	add_child(_win_player)
	if ResourceLoader.exists(SFX_WIN_PATH):
		_win_player.stream = load(SFX_WIN_PATH)


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
	source: StringName
) -> void:
	if source == &"score_pickup" and GameState.water_variant != GameRules.WaterVariant.NONE:
		_play_catch_underwater()
	else:
		play_sfx(SFX_SCORE)


func _play_catch_underwater() -> void:
	if _water_catch_player.stream == null:
		play_sfx(SFX_SCORE)
		return
	_water_catch_player.stop()
	_water_catch_player.play()
	# Cut the clip short so it reads as a single bubble "pop".
	get_tree().create_timer(CATCH_UNDERWATER_DURATION_SECONDS).timeout.connect(
		_water_catch_player.stop)


func _on_water_started(
	_variant: GameRules.WaterVariant,
	_complication: GameRules.WaterComplication,
	_seconds: float
) -> void:
	play_sfx(SFX_WATER)


func _on_powerup_started(_kind: StringName, _seconds: float) -> void:
	play_sfx(SFX_POWERUP)


func _on_game_over(won: bool, _reason: StringName, _score_cents: int) -> void:
	if won and _win_player.stream != null:
		_win_player.play()
	else:
		play_sfx(SFX_WIN if won else SFX_FAIL)
