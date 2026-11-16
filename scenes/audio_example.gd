extends Node

## To add a new sound, go to res://standalones/audio_manager.gd

## This function calls when the node is loaded 
## AKA once before everything else
func _ready() -> void:
	# Connect to signals like this
	# Signals fire when things happen, and you can attatch functions and play
	# when things happen
	SignalBus.steak_eaten.connect(_on_steak_eaten)
func _on_steak_eaten() -> void:
	AudioManager.play(AudioManager.Audio.TEST)


## Example function of how to play stuff
func test() -> void:
	AudioManager.play(AudioManager.Audio.TEST)
