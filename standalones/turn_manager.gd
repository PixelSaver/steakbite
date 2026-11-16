extends Node

enum TurnState {
	MENU,
	POWERUP_ONE,
	STEAK_ONE,
	POWERUP_TWO,
	STEAK_TWO,
	LOSS,
}

var state: TurnState = TurnState.MENU :
	set(val):
		if val == state: return 
		state = val
		SignalBus.game_state_changed.emit(val)

func _ready() -> void:
	SignalBus.game_start.connect(_on_game_start)
	SignalBus.powerup_finished.connect(_on_powerup_finished)
	SignalBus.turn_finished.connect(_on_turn_finished)

func _on_game_start() -> void:
	state = TurnState.POWERUP_ONE

func _on_powerup_finished(is_player_one:bool) -> void:
	state = TurnState.STEAK_TWO if is_player_one else TurnState.STEAK_ONE

func _on_turn_finished(is_player_one:bool) -> void:
	state = TurnState.POWERUP_TWO if is_player_one else TurnState.POWERUP_ONE

## Returns 1 if 1, 2 if 2, and 0 if none.
func player_turn() -> int:
	print("Turnn state is %s" % TurnState.keys()[state])
	if state == TurnState.POWERUP_ONE or state == TurnState.STEAK_ONE:
		return 1
	elif state == TurnState.POWERUP_TWO or state == TurnState.STEAK_TWO:
		return 2
	else: 
		return 0
