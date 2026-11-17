extends Powerup
class_name ShufflePowerup

func apply(_is_player_one: bool, main: Main) -> bool:
	if (!super(_is_player_one, main)): return false
	
	if _is_player_one:
		main.game_2.shuffle_steaks()
	else:
		main.game_1.shuffle_steaks()
	
	# TODO: set player names
	var player_target = "Player 2" if _is_player_one else "Player 1"
	var dialogue = "The steaks have been shuffled on " + player_target + "'s side."
	DialogueManager.show_dialogue_balloon(BLANK, "", [{"dialogue" = dialogue}])
	return true
