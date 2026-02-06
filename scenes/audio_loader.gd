## Global audio manager for dynamic sound effect playback.
##
## This autoload handles the creation, randomization, and cleanup of audio players.
## It supports standard [AudioStreamPlayer] for UI/Global sounds and 
## [AudioStreamPlayer2D] for world-space positional audio.
extends Node

# Sfx / sounds

# var heavy_impact = preload("res://sounds/sfx/heavy_impact.ogg")
# var card_snick = preload("res://sounds/sfx/card_snick.wav")

## Plays a non-positional global sound (e.g., UI or Music). 
## Automatically frees the player once the sound finishes.
func play_sfx(sound: AudioStream, bus = "Master", autoplay = true, volume_modifier = 0.0, pitch_scale = 1.0) -> AudioStreamPlayer:
	var audioPlayer = AudioStreamPlayer.new()
	audioPlayer.stream = sound
	audioPlayer.pitch_scale = pitch_scale
	audioPlayer.autoplay = autoplay
	audioPlayer.finished.connect(audioPlayer.queue_free)
	#audioPlayer.finished.connect(test)
	audioPlayer.bus = bus
	audioPlayer.volume_db += volume_modifier
	get_tree().current_scene.add_child(audioPlayer)
	return audioPlayer

## Same as [method play_sfx], but adds the player via [method Object.call_deferred]. 
## Use this if playing audio during physics callbacks or area signals.
func play_sfx_deferred(sound: AudioStream, bus = "Master", autoplay = true, volume_modifier = 0.0, pitch_scale = 1.0):
	var audioPlayer = AudioStreamPlayer.new()
	audioPlayer.stream = sound
	audioPlayer.pitch_scale = pitch_scale
	audioPlayer.autoplay = autoplay
	audioPlayer.finished.connect(audioPlayer.queue_free)
	#audioPlayer.finished.connect(test)
	audioPlayer.bus = bus
	audioPlayer.volume_db += volume_modifier
	get_tree().current_scene.add_child.call_deferred(audioPlayer)
	return audioPlayer

## Plays a positional 2D sound at a specific [param position] in the current scene.
func play_sfx_2d(sound: AudioStream, bus = "Master", autoplay = true, position = Vector2.ZERO, volume_modifier = 0.0, pitch_scale = 1.0):
	var audioPlayer = AudioStreamPlayer2D.new()
	audioPlayer.stream = sound
	audioPlayer.autoplay = autoplay
	audioPlayer.pitch_scale = pitch_scale
	audioPlayer.finished.connect(audioPlayer.queue_free)
	audioPlayer.bus = bus
	audioPlayer.volume_db += volume_modifier
	get_tree().current_scene.add_child(audioPlayer)
	audioPlayer.global_position = position
	return audioPlayer

## Plays a 2D sound attached to a moving [param parentNode]. 
## The sound will follow the node's position as it moves.
func play_sfx_2d_attached(sound: AudioStream,  parentNode: Node2D, bus = "Master", autoplay = true, volume_modifier=0.0):
	var audioPlayer = AudioStreamPlayer2D.new()
	audioPlayer.stream = sound
	audioPlayer.autoplay = autoplay
	audioPlayer.finished.connect(audioPlayer.queue_free)
	audioPlayer.bus = bus
	audioPlayer.volume_db += volume_modifier
	parentNode.add_child(audioPlayer)
	return audioPlayer

## Same as [method play_sfx_2d], but uses [method Object.call_deferred] to spawn the player.
func play_sfx_2d_deferred(sound: AudioStream, bus = "Master", autoplay = true, position = Vector2.ZERO, volume_modifier = 0.0):
	var audioPlayer = AudioStreamPlayer2D.new()
	audioPlayer.stream = sound
	audioPlayer.autoplay = autoplay
	audioPlayer.finished.connect(audioPlayer.queue_free)
	audioPlayer.bus = bus
	audioPlayer.volume_db += volume_modifier
	get_tree().current_scene.add_child.call_deferred(audioPlayer)
	audioPlayer.global_position = position
	return audioPlayer

# --- UTILITY -----------------------------

func play_item_spawn_sfx(arr: Array):
	return play_sfx(_get_randomized_stream(arr, 1.1))

func play_item_consume_sfx(arr: Array):
	return play_sfx(_get_randomized_stream(arr, 1.2), "Master", true, -10.0, .9)

# Combines multiple streams into a single [AudioStreamRandomizer] for varied playback.
func _get_randomized_stream(arr: Array, pitch_range = 1.0, volume_offset = 0.0):
	var randomAudioStream = AudioStreamRandomizer.new()
	var index = 0
	for stream in arr:
		randomAudioStream.add_stream(index, stream)
		index += 1
	randomAudioStream.random_pitch = pitch_range
	randomAudioStream.random_volume_offset_db = volume_offset
	return randomAudioStream