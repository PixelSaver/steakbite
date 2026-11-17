extends PixelMenu
class_name TurnChangeBanner

signal banner_finished
@export var table: Tweenable
@export var main: Main
@export var rect: TextureRect
@export var left_turn: Texture2D
@export var right_turn: Texture2D
var t: Tween 

func _ready() -> void:
	hide()
	table.tween_value = 1.0

func _update_leftright() -> void:
	if TurnManager.player_turn() == 0: 
		push_warning("Player turn is 0 for some reason in TurnChange")
	rect.texture = right_turn if TurnManager.player_turn() == 2 else left_turn
	

func start_anim() -> void: 
	_update_leftright()
	show()
	if t and t.is_running(): t.kill()
	t = default_tween()
	t.set_parallel(false)
	t.set_trans(Tween.TRANS_ELASTIC)
	t.tween_property(table, "tween_value", 0.0, 0.7)
	t.tween_interval(0.5)
	await t.finished
	end_anim()

func end_anim() -> void: 
	if t and t.is_running(): t.kill()
	t = default_tween()
	t.set_parallel(false).set_ease(Tween.EASE_IN)
	t.tween_property(table, "tween_value", 1.0, 0.5)
	await t.finished
	hide()
