extends Resource
class_name Powerup

@export var name: String = "Powerup"
@export var cost: int = 1
@export_multiline var description: String
@export var id: int = 0
@export var texture: Texture2D
const POOR = preload("uid://br272jxc3fibi")

func apply(_is_player_one: bool, main: Main) -> bool:
	if _is_player_one:
		if main.p1_balance >= cost:
			main.p1_balance -= cost
		else:
			DialogueManager.show_dialogue_balloon(POOR)
			return false
	else:
		if main.p2_balance >= cost:
			main.p2_balance -= cost
		else:
			DialogueManager.show_dialogue_balloon(POOR)
			return false
	return true
