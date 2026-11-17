extends Powerup
class_name FlipSteakPowerup

func apply(_is_player_one: bool, main: Main) -> bool:
	if (!super(_is_player_one, main)): return false
	
	SignalBus.steak_selected.connect(_on_steak_selected.bind(_is_player_one, main))
	
	TurnManager.state = TurnManager.TurnState.CHOOSE_ONE if _is_player_one else TurnManager.TurnState.CHOOSE_TWO
	
	return true

func _on_steak_selected(_steak: SteakTile, pos: Vector2i, _id: int, _is_player_one: bool, main: Main):
	SignalBus.steak_selected.disconnect(_on_steak_selected)
	var map: Array[Array]
	
	if _is_player_one:
		main.game_1.flip_tile(pos)
	else:
		main.game_2.flip_tile(pos)
	
	DialogueManager.show_dialogue_balloon(BLANK, "", [{"dialogue" = "The steak has been flipped."}])
	DialogueManager.dialogue_ended.connect(_on_dialogue_end.bind(_is_player_one))
	

func _on_dialogue_end(_resource: DialogueResource, _is_player_one: bool):
	print("dialogue end called from flip_steak_powerup")
	if _resource != BLANK:
		push_warning("Flip steak powerup dialogue end called from wrong dialogue resource")
	DialogueManager.dialogue_ended.disconnect(_on_dialogue_end)
	TurnManager.state = TurnManager.TurnState.POWERUP_ONE if _is_player_one else TurnManager.TurnState.POWERUP_TWO
	pass
