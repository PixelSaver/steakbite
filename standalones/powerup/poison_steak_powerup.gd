extends Powerup
class_name PoisonSteakPowerup

@export var steak_min: int = 1
@export var steak_max: int = 2

func apply(_is_player_one: bool, main: Main) -> bool:
	if (!super(_is_player_one, main)): return false
	
	var num_poison = randi_range(steak_min, steak_max)
	var target_game = main.game_2 if _is_player_one else main.game_1
	for i in num_poison:
		target_game.add_poison()
	# TODO: set player names
	var player_target = "Player 2" if _is_player_one else "Player 1"
	var dialogue = str(num_poison) + " poisoned steaks have been added to " + player_target + "'s side."
	DialogueManager.show_dialogue_balloon(BLANK, "", [{"dialogue" = dialogue}])
	return true
