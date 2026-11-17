extends PixelMenu
class_name DeathScreen

const LOSS = preload("uid://dgvrmatmr6fv6")
@export var texture_rect: TextureRect
@export var left_survived_texture: Texture2D
@export var right_survived_texture: Texture2D
@export var table: Tweenable
@export var balloon: CloseUpBalloon
var t: Tween 

func _ready() -> void: 
	hide()
	SignalBus.player_died.connect(_on_player_died)

func _on_player_died(is_right: bool) -> void:
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
	balloon.start(LOSS)
	balloon.grab_focus()
	await balloon.dialogue_finished
	
	end_anim()

#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("ui_accept") and TurnManager.state == TurnManager.TurnState.LOSS:
		#end_anim()
func end_anim() -> void: 
	if TurnManager.state != TurnManager.TurnState.LOSS:
		return
	print("Ending")
	hide()
	TurnManager.state = TurnManager.TurnState.MENU
