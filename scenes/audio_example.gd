extends Node

## To add a new sound, go to res://standalones/audio_manager.gd

# I will try to add a bunch of points that sounds could be added, like so
#SOUND Example that needs no sound
# Use Ctrl+Shift+F to find stuff and click around :D DM me if questions

## This function calls when the node is loaded 
## AKA once before everything else
func _ready() -> void:
	# Connect to signals like this
	# Signals fire when things happen, and you can attatch functions and play
	# when things happen
	SignalBus.steak_eaten.connect(_on_steak_eaten)
func _on_steak_eaten() -> void:
	AudioManager.play(AudioManager.Audio.TEST)
	
	# if u want music volume to be separate (default is "SFX")
	AudioManager.play(AudioManager.Audio.TEST, 0., "Music")
	
	# if you want to loop (only works for wav, mp3, ogg files)
	AudioManager.play(AudioManager.Audio.TEST, 0., "Music", true)
	
	# if you want louder
	AudioManager.play(AudioManager.Audio.TEST, 10.)
	

## Example function of how to play stuff
func test() -> void:
	AudioManager.play(AudioManager.Audio.TEST)
