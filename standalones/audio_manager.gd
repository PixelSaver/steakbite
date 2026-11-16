extends Node


# To add a new sound, first add a new name to Audio (example here is `test`)
# Then, add a row to `const SOUNDS` so that it's
# Audio.NAME: "path/to/sound"
# BTW, if you right click on an asset, you can then click copy path :D
enum Audio {
	TEST,
	MAIN_THEME,
	TITLE,
	AltMain_THEME,
	EatConfirmPlate,
	SpotlightOff,
	buttonHover,
	getPoisoned,
	steakZoomIn,
	steakPass,
	emptyTable,
	steakSelected,
	powerMenuFlipDown,
	powerUpHover,
	powerUpBought,
	powerMenuFlipUp,
	InvalidOption,
	EndTurn,
}
const SOUNDS: Dictionary[Audio, String] = {
	Audio.TEST: "res://assets/sounds/test.wav",
	Audio.MAIN_THEME: "res://assets/music/main_theme.ogg",
	Audio.TITLE: "res://assets/sounds/Somber Orchestra.mp3",
	Audio.AltMain_THEME: "res://assets/sounds/Horror_Ambience_Steakbite.mp3",
	Audio.EatConfirmPlate: "res://assets/sounds/EatConfirmPlate",
	Audio.SpotlightOff: "res://assets/sounds/SpotlightOff",
	Audio.buttonHover: "res://assets/sounds/ButtonHoverSteak",
	Audio.getPoisoned: "res://assets/sounds/GetPoisoned",
	Audio.powerMenuFlipDown: "res://assets/sounds/LowerMenu",
	

	
}
# Music tracks use the dedicated music player.
const MUSIC_TRACKS: Array[Audio] = [
	Audio.MAIN_THEME,
	Audio.TITLE,
	Audio.AltMain_THEME,
]

#region AudioManager
var sounds: Dictionary[Audio, AudioStream] = {}
var players: Array[AudioStreamPlayer] = []
var music_player: AudioStreamPlayer

func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	add_child(music_player)

func play(
	sound: Audio,
	volume: float = 0.0,
	bus: String = "SFX",
	loop: bool = false,
) -> void:
	if not sounds.has(sound):
		var path := SOUNDS[sound]
		var _stream := load(path) as AudioStream
		if _stream == null:
			push_error("Failed to load audio: " + path)
			return
		sounds[sound] = _stream
	
	var stream := sounds[sound]
	if stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD if loop else AudioStreamWAV.LOOP_DISABLED
	elif stream is AudioStreamOggVorbis:
		stream.loop = loop
	elif stream is AudioStreamMP3:
		stream.loop = loop

	var player: AudioStreamPlayer
	if sound in MUSIC_TRACKS:
		player = music_player
	else:
		player = _get_available_player()
	player.stream = stream
	player.bus = bus
	player.volume_db = volume
	player.play()

func stop_music() -> void:
	music_player.stop()

func _get_available_player() -> AudioStreamPlayer:
	for player in players:
		if not player.playing:
			return player
	var player := AudioStreamPlayer.new()
	add_child(player)
	players.append(player)
	return player
#endregion
