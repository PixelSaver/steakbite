extends Powerup
class_name CheckSteakPowerup

func _ready():
	SignalBus.steak_selected.connect(_on_steak_selected)

func apply(_is_player_one: bool, main: Main) -> bool:
	if (!super(_is_player_one, main)): return false
	
	TurnManager.state = TurnManager.TurnState.CHOOSE_ONE if _is_player_one else TurnManager.TurnState.CHOOSE_TWO
	SignalBus.game_state_changed.emit(TurnManager.state)
	
	#if _is_player_one:
		#main.game_2.shuffle_steaks()
	#else:
		#main.game_1.shuffle_steaks()
	#
	#var player_target = "Player 2" if _is_player_one else "Player 1"
	#var dialogue = "The steaks have been shuffled on " + player_target + "'s side."
	#DialogueManager.show_dialogue_balloon(BLANK, "", [{"dialogue" = dialogue}])
	return true

func _on_steak_selected():
	print("steak selected in the powerup thing!")
