extends Control
class_name CloseUpMenu

@export var main: Main
const CLOSEUP_BALLOON = preload("uid://cfrjwymq0mu44")
@export var butler: TextureRect
@export var balloon: CloseUpBalloon
@export var panel: Panel
@export var resource: DialogueResource
@export var game1: GameContainer
@export var game2: GameContainer
@export var steaks: Array[TextureRect]
@export var eat_delay: float = 0.5
var t: Tween
var selected_steak_pos: Vector2i = Vector2i.MIN

func _get_balloon_control() -> Control:
	for child in balloon.get_children():
		if child is Control:
			return child
	push_error("Closeup Balloon doesn't have a child control")
	return null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	butler.offset_transform_enabled = true
	butler.offset_transform_position_ratio.x = -.75
	panel.modulate.a = 0.0
	_get_balloon_control().modulate.a = 0.0
	#start_anim()
	SignalBus.steak_selected.connect(_on_steak_selected)
	DialogueManager.dialogue_ended.connect(_on_dialogue_end)
	SignalBus.close_up_menu_closed.connect(func(confirmed: String):
		
		if confirmed == "yes": confirm()
		else: deny()
	)
	if not main: start_anim()

func _on_dialogue_end(_resource):
	if (_resource == CLOSEUP_BALLOON):
		end_anim()
	else:
		print("dialogue end called from closeup_scene incorrectly")

func _on_steak_selected(_steak: SteakTile, pos: Vector2i, _id: int) -> void:
	if TurnManager.state == TurnManager.TurnState.STEAK_ONE or \
	TurnManager.state == TurnManager.TurnState.STEAK_TWO:
		selected_steak_pos = pos
		start_anim()

func confirm() -> void:
	if selected_steak_pos < Vector2i(0, 0):
		push_warning("Vector position is invalid. Not initialized in CloseUpMenu?")
		return
	balloon.hide()
	for i in range(steaks.size()):
		steaks[i].show()
		if i > 0:
			steaks[i - 1].hide()
		await get_tree().create_timer(eat_delay).timeout
	if not steaks.is_empty():
		steaks[-1].hide()
	var player_id = TurnManager.player_turn()
	var game: GameContainer = main.game_1 if player_id == 1 else main.game_2
	game.eat_steak(selected_steak_pos)
	await get_tree().create_timer(eat_delay).timeout
	end_anim()
	#SOUND steak eating animation sound
	AudioManager.play(AudioManager.Audio.EatConfirmPlate, -1, "SFX")
func deny():
	await get_tree().create_timer(0.5).timeout
	end_anim()
	if selected_steak_pos < Vector2i(0,0):
		push_warning("Vector position is invalid. Not initialized in CloseUpMenu?")
		return

func start_anim() -> void:
	show()
	for i in range(steaks.size()):
		steaks[i].visible = (i == 0)
	if t and t.is_running():
		t.kill()
	t = create_tween().set_ease(Tween.EASE_OUT)
	t.set_trans(Tween.TRANS_QUINT).set_parallel(true)
	t.tween_property(butler, "offset_transform_position_ratio:x", 0.0, 0.6)
	t.tween_property(panel, "modulate:a", 1.0, 0.6)
	t.tween_property(_get_balloon_control(), "modulate:a", 1.0, 0.6)
	t.tween_callback(func():
		balloon.show()
		balloon.start(resource)
	).set_delay(0.3)
	

func end_anim() -> void:
	balloon.hide()
	if t and t.is_running(): t.kill()
	t = create_tween().set_ease(Tween.EASE_OUT)
	t.set_trans(Tween.TRANS_QUINT).set_parallel(true)
	t.tween_property(butler, "offset_transform_position_ratio:x", -.75, 0.6)
	t.tween_property(panel, "modulate:a", 0.0, 0.6)
	t.tween_property(_get_balloon_control(), "modulate:a", 0.0, 0.6)
	await t.finished
	if TurnManager.state == TurnManager.TurnState.STEAK_ONE:
		game1.grab_first_focus()
	else:
		game2.grab_first_focus()
	hide()
