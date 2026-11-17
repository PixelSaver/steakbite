extends Node
class_name ButlerSpeakComponent

var parent: DialogueLabel

@export var sound_cooldown: float = 0.2

var last_sound_time: float = 0.0

func _ready() -> void:
	parent = get_parent()
	if not parent: return
	parent.spoke.connect(_on_spoke)

func _on_spoke(letter: String, letter_index: int, speed: float) -> void:
	if letter in [".", " "]:
		return
	var now := Time.get_ticks_msec() / 1000.0
	if now - last_sound_time < sound_cooldown:
		return
	last_sound_time = now - randf_range(0, 0.2)
	AudioManager.play(AudioManager.Audio.BUTLER_TALK, -5, "SFX", false, 0.12)
