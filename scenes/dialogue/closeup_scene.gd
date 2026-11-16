extends Control
class_name CloseUpMenu

@export var main: Main
const CLOSEUP_BALLOON = preload("uid://cfrjwymq0mu44")
@export var resource: DialogueResource

var selected_steak_pos: Vector2i = Vector2i.MIN

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#start_anim()
	SignalBus.steak_selected.connect(_on_steak_selected)
	DialogueManager.dialogue_ended.connect(_on_dialogue_end)

func _on_dialogue_end(_resource):
	print("dialogue ended")
	end_anim()

func _on_steak_selected(_steak: SteakTile, pos: Vector2i, _id: int) -> void:
	selected_steak_pos = pos
	start_anim()

func confirm() -> void:
	if selected_steak_pos < Vector2i(0,0):
		push_warning("Vector position is invalid. Not initialized in CloseUpMenu?")
		return
	
	var player_id = TurnManager.player_turn()
	#assert((player_id == 1 or player_id == 2), "Player id from TurnManager isn't 1 or 2 in CloseUp")
	var game: GameContainer = main.game_1 if player_id == 1 else main.game_2
	game.eat_steak(selected_steak_pos)
	
func deny():
	if selected_steak_pos < Vector2i(0,0):
		push_warning("Vector position is invalid. Not initialized in CloseUpMenu?")
		return

func start_anim() -> void:
	show()
	DialogueManager.show_dialogue_balloon_scene(CLOSEUP_BALLOON, resource, "", [self])

func end_anim() -> void:
	hide()
