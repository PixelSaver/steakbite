extends Node

@warning_ignore("unused_signal")
signal test(test: bool)
@warning_ignore("unused_signal")
signal game_start()
@warning_ignore("unused_signal")
signal powerup_finished(is_player_one:bool)
@warning_ignore("unused_signal")
signal turn_finished(is_player_one:bool)
@warning_ignore("unused_signal")
signal game_state_changed(new_game_state: TurnManager.TurnState)
@warning_ignore("unused_signal")
signal steak_selected(steak: SteakTile, pos: Vector2i, id: int)
@warning_ignore("unused_signal")
## Signal for when a steak is eaten
signal steak_eaten(steak: SteakTile)

func _ready() -> void:
	SignalBus.game_start.connect(_test)

func _test() -> void:
	print("jeu")
	test.emit(true)
