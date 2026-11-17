extends PixelMenu
class_name StartMenu

@export var buttons: Array[DefaultButton]
@export var table: Tweenable
var all_t : Array[Tweenable] = []
var t: Tween 

func _ready() -> void: 
	all_t = get_all_tweenables(self)
	for but in buttons:
		but.pressed.connect(_on_button_pressed.bind(but.name))
	start_anim()
	AudioManager.play(AudioManager.Audio.TITLE, -15, "MUSIC", true)

	SignalBus.game_state_changed.connect(_on_game_state_changed)

func _on_button_pressed(_name:String) -> void:
	match _name.to_lower():
		"play":
			SignalBus.game_start.emit()
			AudioManager.stop_music()
			AudioManager.play(AudioManager.Audio.altMainTheme, -12, "MUSIC", true)
			#TurnManager.state = TurnManager.TurnState.POWERUP_ONE
		"settings":
			pass
		"credits":
			pass
		"quit":
			pass
			#TODO If we have time, do a butler being angry thing
		_:
			push_warning("PixelMenu(%s) failed to find button name <%s>" % [self, _name])

func _on_game_state_changed(new_state: TurnManager.TurnState) -> void:
	if new_state == TurnManager.TurnState.MENU:
		start_anim()
	else:
		end_anim()

func start_anim() -> void: 
	show()
	buttons.front().grab_focus()
	if t and t.is_running(): t.kill()
	t = default_tween()
	t.tween_property(table, "tween_value", 0.0, 0.7)
	t.tween_property(self, "modulate:a", 1.0, 0.7)
func end_anim() -> void: 
	if t and t.is_running(): t.kill()
	t = default_tween()
	t.tween_property(table, "tween_value", 1.0, 0.7)
	t.tween_property(self, "modulate:a", 0.0, 0.7)
	await t.finished
	hide()
