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
@export var no_steak_panel: Panel
@export var no_steak_balloon: CloseUpBalloon
@export var no_steak_tweenable: Tweenable
@export var death_screen: DeathScreen
const NO_STEAK = preload("uid://bvwdwfqkkrpbv")

var p1_balance: int = 0
var p2_balance: int = 0

var p1_lives: int = 2
var p2_lives: int = 2
var t: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	no_steak_tweenable.tween_value = 1.0
	no_steak_panel.modulate.a = 0.0
	SignalBus.game_state_changed.connect(_on_game_state_changed)
	#DEBUG
	SignalBus.game_start.connect(start_game)
	end_turn_1.pressed.connect(_on_end_turn.bind(1))
	end_turn_2.pressed.connect(_on_end_turn.bind(2))

func _on_end_turn(id:int) -> void:
	if id == 1 and TurnManager.state == TS.STEAK_ONE:
		if game_1.steaks_eaten_this_round > 0:
			TurnManager.state = TS.POWERUP_TWO
			#SOUND Ended turn for player 1
			
			
		else:
			_no_steak_cutscene()
	elif id == 2 and TurnManager.state == TS.STEAK_TWO:
		if game_2.steaks_eaten_this_round > 0:
			TurnManager.state = TS.POWERUP_ONE
			#SOUND Ended turn for player 1
			
		else:
			_no_steak_cutscene()
	else:
		push_error(
			"Impossible end turn request: TurnManager state=%s, id of end_turn=%s" % 
			[TS.keys()[TurnManager.state], id]
		)

func _no_steak_cutscene() -> void:
	no_steak_tweenable.tween_value = 1.0
	no_steak_panel.modulate.a = 0.0
	no_steak_balloon.start(NO_STEAK)
	if t and t.is_running(): t.kill()
	t = create_tween().set_ease(Tween.EASE_OUT)
	t.set_trans(Tween.TRANS_QUINT).set_parallel(true)
	t.tween_property(no_steak_tweenable, "tween_value", 0.0, 0.7)
	t.tween_property(no_steak_panel, "modulate:a", 1.0, 0.7)
	
	await no_steak_balloon.dialogue_finished
	
	if t and t.is_running(): t.kill()
	t = create_tween().set_ease(Tween.EASE_OUT)
	t.set_trans(Tween.TRANS_QUINT).set_parallel(true)
	t.tween_property(no_steak_tweenable, "tween_value", 1.0, 0.7)
	t.tween_property(no_steak_panel, "modulate:a", 0.0, 0.7)
	
func _input(event: InputEvent) -> void:
	if OS.is_debug_build():
		if event.is_action_pressed("1"):
			SignalBus.player_died.emit(false)
			TurnManager.state = TurnManager.TurnState.LOSS
func start_game() -> void:
	TurnManager.state = TurnManager.TurnState.POWERUP_ONE

func _on_game_state_changed(new_state: TS) -> void:
	print("Turn state is %s" % TurnManager.TurnState.keys()[new_state])
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
		TS.CHOOSE_ONE:
			end_turn_1.hide()
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
		TS.CHOOSE_TWO:
			end_turn_1.hide()
			end_turn_2.hide()
			game_2.grab_first_focus()
		TS.LOSS:
			end_turn_1.hide()
			end_turn_2.hide()
			#await get_tree().create_timer(1.0).timeout
			#death_screen.start_anim()
			#DialogueManager.show_dialogue_balloon(LOSS, "", [self])
			pass

func get_winning_player() -> String:
	if p1_lives > 0:
		return "Player 1"
	elif p2_lives > 0:
		return "Player 2"
	else:
		return "no one"
		
func play_again():
	get_tree().reload_current_scene()

func exit_to_menu():
	# TODO
	get_tree().reload_current_scene()
