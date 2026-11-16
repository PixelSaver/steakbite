extends Control
class_name Main

## Lazy to type this out
const TS = TurnManager.TurnState
## Game for player 1; left
@export var game_1: GameContainer
## Game for player 2; right
@export var game_2: GameContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.game_state_changed.connect(_on_game_state_changed)
	#DEBUG
	start_game()

func start_game() -> void:
	TurnManager.state = TurnManager.TurnState.STEAK_ONE

func _on_game_state_changed(new_state: TS) -> void:
	match new_state:
		TS.MENU:
			pass
		TS.POWERUP_ONE:
			pass
		TS.STEAK_ONE:
			game_1.grab_first_focus()
		TS.POWERUP_TWO:
			pass
		TS.STEAK_TWO:
			game_2.grab_first_focus()
		TS.LOSS:
			pass
