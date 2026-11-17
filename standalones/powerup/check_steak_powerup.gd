extends Powerup
class_name CheckSteakPowerup

@export var uses: int = 2

var curr_uses: int

func apply(_is_player_one: bool, main: Main) -> bool:
	if (!super(_is_player_one, main)): return false
	
	curr_uses = uses
	SignalBus.steak_selected.connect(_on_steak_selected.bind(_is_player_one, main))
	
	TurnManager.state = TurnManager.TurnState.CHOOSE_ONE if _is_player_one else TurnManager.TurnState.CHOOSE_TWO
	
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
		curr_uses -= 1
		if curr_uses <= 0:
			SignalBus.steak_selected.disconnect(_on_steak_selected)
		DialogueManager.dialogue_ended.connect(_on_dialogue_end.bind(_is_player_one, curr_uses, main))
	elif tile == GameContainer.TileType.STEAK_BAD:
		dialogue = "This steak is poisoned."
		curr_uses -= 1
		if curr_uses <= 0:
			SignalBus.steak_selected.disconnect(_on_steak_selected)
		DialogueManager.dialogue_ended.connect(_on_dialogue_end.bind(_is_player_one, curr_uses, main))
	else:
		dialogue = "This tile is empty. Please choose another one."
		
	DialogueManager.show_dialogue_balloon(BLANK, "", [{"dialogue" = dialogue}])
	pass

func _on_dialogue_end(_resource: DialogueResource, _is_player_one: bool, curr_uses: int, main: Main):
	print("dialogue end called from check_steak_powerup")
	if _resource != BLANK:
		push_warning("Check steak powerup dialogue end called from wrong dialogue resource")
	DialogueManager.dialogue_ended.disconnect(_on_dialogue_end)
	if curr_uses <= 0:
		TurnManager.state = TurnManager.TurnState.POWERUP_ONE if _is_player_one else TurnManager.TurnState.POWERUP_TWO
	else:
		if _is_player_one: main.game_1.grab_first_focus()
		else: main.game_2.grab_first_focus()
	pass
