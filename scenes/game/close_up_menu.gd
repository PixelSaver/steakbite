extends PixelMenu

@export var yes: Button
@export var no: Button
@export var main: Main
var selected_steak_pos: Vector2i = Vector2i.MIN
var t: Tween

func _ready() -> void:
	yes.pressed.connect(_on_button_pressed.bind(true))
	no.pressed.connect(_on_button_pressed.bind(false))
	#get_viewport().gui_focus_changed.connect(_on_focus_changed)
	SignalBus.steak_selected.connect(_on_steak_selected)

func _on_steak_selected(_steak: SteakTile, pos: Vector2i, _id: int) -> void:
	selected_steak_pos = pos
	start_anim()

#func _on_focus_changed(node: Control) -> void:
	#if node != self:
		#end_anim()

func _on_button_pressed(confirm:bool) -> void:
	if selected_steak_pos < Vector2i(0,0):
		push_warning("Vector position is invalid. Not initialized in CloseUpMenu?")
		return
	
	if confirm:
		var player_id = TurnManager.player_turn()
		#assert((player_id == 1 or player_id == 2), "Player id from TurnManager isn't 1 or 2 in CloseUp")
		var game: GameContainer = main.game_1 if player_id == 1 else main.game_2
		game.eat_steak(selected_steak_pos)
		end_anim()
	else:
		self.end_anim()

func start_anim() -> void:
	show()
	yes.grab_focus()

func end_anim() -> void:
	SignalBus.close_up_menu_closed.emit()
	hide()
