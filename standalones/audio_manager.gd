extends Node


# To add a new sound, first add a new name to Audio (example here is `test`)
# Then, add a row to `const SOUNDS` so that it's
# Audio.NAME: "path/to/sound"
# BTW, if you right click on an asset, you can then click copy path :D
enum Audio {
	TEST,
}
const SOUNDS: Dictionary[Audio, String] = {
	Audio.TEST: "res://assets/sounds/test.wav"
}

#region AudioManager code
var sounds: Dictionary[Audio, AudioStream] = {}
var players: Array[AudioStreamPlayer] = []

func play(sound: Audio) -> void:
	if not sounds.has(sound):
		var path := SOUNDS[sound]
		var stream := load(path) as AudioStream
		
		if stream == null:
			push_error("Failed to load audio: " + path)
			return
			
		sounds[sound] = stream
		
	var player := _get_available_player()
	player.stream = sounds[sound]
	player.play()


func _get_available_player() -> AudioStreamPlayer:
	for player in players:
		if not player.playing:
			return player
			
	var player := AudioStreamPlayer.new()
	add_child(player)
	players.append(player)
	
	return player
#endregion
