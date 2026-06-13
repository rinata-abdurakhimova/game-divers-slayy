extends Node

var _sounds: Dictionary[StringName, AudioStream] = {}
var _sfx_player: AudioStreamPlayer


func _ready() -> void:
	_sfx_player = AudioStreamPlayer.new()
	_sfx_player.name = "SFXPlayer"
	add_child(_sfx_player)


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

