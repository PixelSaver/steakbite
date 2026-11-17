extends Powerup
class_name CheckSteakPowerup

func apply(_is_player_one: bool, main: Main) -> bool:
	if (!super(_is_player_one, main)): return false
	
	print("did apply work???")
	SignalBus.steak_selected.connect(_on_steak_selected.bind(_is_player_one, main))
	
	TurnManager.state = TurnManager.TurnState.CHOOSE_ONE if _is_player_one else TurnManager.TurnState.CHOOSE_TWO
	SignalBus.game_state_changed.emit(TurnManager.state)
	
	return true

func _on_steak_selected(_steak: SteakTile, pos: Vector2i, _id: int, _is_player_one: bool, main: Main):
	var map: Array[Array]
	
	if _is_player_one:
		map = main.game_1.map
	else:
		map = main.game_2.map
		
	var tile: GameContainer.TileType = map[pos.y][pos.x]
	var dialogue: String
	if tile == GameContainer.TileType.STEAK_GOOD:
		dialogue = "This steak is safe."
		SignalBus.steak_selected.disconnect(_on_steak_selected)
		DialogueManager.dialogue_ended.connect(_on_dialogue_end.bind(_is_player_one))
	elif tile == GameContainer.TileType.STEAK_BAD:
		dialogue = "This steak is poisoned."
		SignalBus.steak_selected.disconnect(_on_steak_selected)
		DialogueManager.dialogue_ended.connect(_on_dialogue_end.bind(_is_player_one))
	else:
		dialogue = "This tile is empty. Please choose another one."
		
	DialogueManager.show_dialogue_balloon(BLANK, "", [{"dialogue" = dialogue}])
	pass

func _on_dialogue_end(_resource: DialogueResource, _is_player_one: bool):
	print("dialogue end called from check_steak_powerup")
	if _resource != BLANK:
		push_warning("Check steak powerup dialogue end called from wrong dialogue resource")
	DialogueManager.dialogue_ended.disconnect(_on_dialogue_end)
	TurnManager.state = TurnManager.TurnState.POWERUP_ONE if _is_player_one else TurnManager.TurnState.POWERUP_TWO
	pass
