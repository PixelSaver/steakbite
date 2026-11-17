extends PixelMenu
class_name DeathScreen

@export var texture_rect: TextureRect
@export var left_survived_texture: Texture2D
@export var right_survived_texture: Texture2D
@export var table: Tweenable
const LOSS = preload("uid://dgvrmatmr6fv6")
const DEATH_BALLOON = preload("uid://cx8cay0aoexl7")
var t: Tween 

var right_side_dead: bool

func _ready() -> void: 
	hide()
	SignalBus.player_died.connect(_on_player_died)


func _on_player_died(is_right: bool) -> void:
	right_side_dead = is_right
	if is_right: 
		texture_rect.texture = left_survived_texture
	else: 
		texture_rect.texture = right_survived_texture
	start_anim()

func start_anim() -> void: 
	await get_tree().create_timer(1.0).timeout
	show()
	if t and t.is_running(): t.kill()
	t = create_tween().set_ease(Tween.EASE_OUT)
	t.set_trans(Tween.TRANS_QUINT).set_parallel(true)
	t.tween_property(table, "tween_value", 1.0, 0.7)
	#t.tween_property(no_steak_panel, "modulate:a", 0.0, 0.7)
	#balloon.start(LOSS)
	#balloon.balloon.grab_focus()
	#await get_tree().process_frame
	#balloon.balloon.grab_focus()
	#await balloon.dialogue_finished
	var player_name = "Player 1" if right_side_dead else "Player 2"
	DialogueManager.show_dialogue_balloon_scene(DEATH_BALLOON, LOSS, "", [{"winning_player" = player_name}])
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	#end_anim()

#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("ui_accept") and TurnManager.state == TurnManager.TurnState.LOSS:
		#end_anim()
		
		

func _on_dialogue_ended(_resource: DialogueResource):
	if (_resource == LOSS):
		end_anim()
		DialogueManager.dialogue_ended.disconnect(_on_dialogue_ended)

func end_anim() -> void: 
	if TurnManager.state != TurnManager.TurnState.LOSS:
		return
	print("Ending")
	hide()
	get_tree().reload_current_scene()
