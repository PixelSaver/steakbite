extends Control
class_name Main

## Lazy to type this out
const TS = TurnManager.TurnState
## Game for player 1; left
@export var game_1: GameContainer
## Game for player 2; right
@export var game_2: GameContainer
@export var end_turn_1: DefaultButton
@export var end_turn_2: DefaultButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.game_state_changed.connect(_on_game_state_changed)
	#DEBUG
	start_game()
	end_turn_1.pressed.connect(_on_end_turn.bind(1))
	end_turn_2.pressed.connect(_on_end_turn.bind(2))

func _on_end_turn(id:int) -> void:
	if id == 1 and TurnManager.state == TS.STEAK_ONE:
		if game_1.steaks_eaten_this_round > 0:
			TurnManager.state = TS.POWERUP_TWO
		else:
			#TODO Get butler to chide you for not eating
			pass
	elif id == 2 and TurnManager.state == TS.STEAK_TWO:
		if game_2.steaks_eaten_this_round > 0:
			TurnManager.state = TS.POWERUP_ONE
		else:
			#TODO Get butler to chide you for not eating
			pass
	else:
		push_error(
			"Impossible end turn request: TurnManager state=%s, id of end_turn=%s" % 
			[TS.keys()[TurnManager.state], id]
		)

func start_game() -> void:
	TurnManager.state = TurnManager.TurnState.STEAK_ONE

func _on_game_state_changed(new_state: TS) -> void:
	print("game state changing to: " + str(new_state))
	match new_state:
		TS.MENU:
			pass
		TS.POWERUP_ONE:
			end_turn_1.hide()
			end_turn_2.hide()
			pass
		TS.STEAK_ONE:
			end_turn_1.show()
			end_turn_2.hide()
			game_1.grab_first_focus()
		TS.POWERUP_TWO:
			end_turn_1.hide()
			end_turn_2.hide()
			pass
		TS.STEAK_TWO:
			end_turn_1.hide()
			end_turn_2.show()
			game_2.grab_first_focus()
		TS.LOSS:
			pass
