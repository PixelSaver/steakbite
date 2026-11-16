@tool
extends AspectRatioContainer
class_name GameContainer

const TS = TurnManager.TurnState
enum TileType {
	EMPTY,
	STEAK_GOOD,
	STEAK_BAD,
}
const STEAK_TILE = preload("res://scenes/tiles/steak_tile.tscn")
const EMPTY_TILE = preload("res://scenes/tiles/empty_tile.tscn")
@export_subgroup("Nodes")
@onready var control: Control = $Game/SubViewport/Control
@export var left_visual: Control
@export var right_visual: Control
@export var subviewport: SubViewport
@export var game_subviewport_container: SubViewportContainer
@export var spotlight: Node2D
## x, y size
@export var grid_container : GridContainer
@export_category("Tweaks")
@export var map_size := Vector2i(5, 4)
@export var margin_bottom : int = 100
@export var margin_sides : int = 100
@export var num_poisoned := 8
@export var spotlight_offset := Vector2i(0,0)
@export var is_right := false :
	set(val):
		is_right = val
		_update_leftright()
@export_tool_button("Place") var place_steaks = _on_game_start
var spotlight_target_pos := Vector2.ZERO
var spotlight_tween: Tween
var map : Array[Array] 
## Randomized queue of clean steaks
var clean_steaks : Array[Vector2i]
var visual_tiles: Array[Control] = []
var steaks_eaten_this_round := 0
var main: Main

func _ready() -> void:
	var scene_root = get_tree().current_scene
	main = scene_root as Main
	if not main and scene_root != self:
		push_warning("Main isn't scene root for Game")
	#assert((main and get_tree().current_scene != self), "Main isn't scene for Game")
	spotlight.modulate.a = 0.0
	_update_leftright()
	_on_game_start()
	# ignoring rest if it's the editor, globals don't exist there
	if Engine.is_editor_hint(): return
	SignalBus.game_start.connect(_on_game_start)
	SignalBus.game_state_changed.connect(_on_game_state_changed)
	SignalBus.close_up_menu_closed.connect(func():
		if TurnManager.player_turn() == (int(is_right) + 1):
			await get_tree().process_frame
			grab_first_focus()
	)
	subviewport.gui_focus_changed.connect(_on_focus_changed)
	get_viewport().gui_focus_changed.connect(func(node: Control): 
		if node != game_subviewport_container and node != self: 
			_hide_spotlight()
			return
		grab_first_focus()
	)
	var end_turn = _get_end_turn()
	end_turn.focus_entered.connect(_on_focus_changed.bind(end_turn))
	#end_turn.focus_exited.connect(_on_focus_changed.bind(end_turn))

func enable_focus(enable:bool) -> void:
	subviewport.set_process_input(enable)
	self.focus_mode = Control.FOCUS_ALL if enable else Control.FOCUS_NONE
	self.mouse_filter = Control.MOUSE_FILTER_PASS if enable else Control.MOUSE_FILTER_IGNORE

func _on_game_state_changed(new_state: TS) -> void:
	steaks_eaten_this_round = 0
	match new_state:
		TS.MENU:
			pass
		TS.POWERUP_ONE or TS.STEAK_ONE:
			enable_focus(not is_right)
		TS.POWERUP_TWO or TS.STEAK_TWO:
			enable_focus(is_right)
		TS.LOSS:
			pass

func _on_steak_selected(steak: SteakTile) -> void:
	var idx = visual_tiles.find(steak)
	if idx == -1: 
		push_warning("Steak selected, and yet wasn't found in GameContainer's visual_tiles array")
		return
	var pos = _get_grid_position(idx)
	SignalBus.steak_selected.emit(steak, pos, TurnManager.player_turn())

func _update_leftright() -> void:
	if is_right:
		left_visual.hide()
		right_visual.show()
	else:
		left_visual.show()
		right_visual.hide()

#region Focus stuff
func grab_first_focus(skip_empty_tiles: bool=true) -> void:
	for tile in visual_tiles:
		if skip_empty_tiles:
			var idx = visual_tiles.find(tile)
			var pos = _get_grid_position(idx)
			if get_tile_type(pos) == TileType.EMPTY:
				continue
		tile.grab_focus()
		return
	_get_end_turn().grab_focus()

func _get_end_turn() -> Button:
	return main.end_turn_2 if is_right else main.end_turn_1
func _on_focus_changed(node: Control) -> void:
	if Engine.is_editor_hint(): return
	var end_turn = _get_end_turn()
	var idx = visual_tiles.find(node)
	if idx != -1: 
		var length = visual_tiles.size()
		# adding row length to move down a row
		# if outside bounds, set to itself (ignoring other ui for now)
		var bottom_neighbor_idx = idx + map_size.x 
		if bottom_neighbor_idx < length:
			var target = visual_tiles[bottom_neighbor_idx]
			node.focus_neighbor_bottom = node.get_path_to(target)
		else:
			node.focus_neighbor_bottom = node.get_path_to(end_turn)
			end_turn.focus_neighbor_top = end_turn.get_path_to(node)
			
		var top_neighbor_idx = idx - map_size.x 
		if top_neighbor_idx >= 0:
			var target = visual_tiles[top_neighbor_idx]
			node.focus_neighbor_top = node.get_path_to(target)
	elif node != end_turn:
		return
	
	# highlight
	var spotlight_target: Vector2 = node.global_position + node.size * 0.5
	if node == end_turn:
		spotlight_target -= game_subviewport_container.global_position
	if spotlight_tween and spotlight_tween.is_running(): spotlight_tween.kill()
	spotlight_tween = create_tween().set_ease(Tween.EASE_OUT)
	spotlight_tween.set_trans(Tween.TRANS_QUINT).set_parallel(true)
	spotlight_tween.tween_property(self, "spotlight_target_pos", spotlight_target, 0.7)
	spotlight_tween.tween_property(spotlight, "modulate:a", 1.0, 0.7)

func _hide_spotlight() -> void:
	#SOUND Spotlight turns off
	if spotlight_tween and spotlight_tween.is_running(): spotlight_tween.kill()
	spotlight_tween = create_tween().set_ease(Tween.EASE_OUT)
	spotlight_tween.set_trans(Tween.TRANS_QUINT).set_parallel(true)
	#spotlight_tween.tween_property(self, "spotlight_target_pos", Vector2.ZERO, 0.7)
	spotlight_tween.tween_property(spotlight, "modulate:a", 0.0, 0.7)
	

func _process(_delta: float) -> void:
	if Engine.is_editor_hint(): return
	var spotlight_corner := Vector2.ZERO
	if is_right:
		spotlight_corner = Vector2(
			subviewport.size.x - spotlight_offset.x, 
			spotlight_offset.y
		)
	else:
		spotlight_corner = spotlight_offset
	spotlight.position = spotlight_target_pos
	spotlight.look_at(spotlight_corner)
	spotlight.rotate(PI/2)
	spotlight.rotation = fmod(spotlight.rotation, 2*PI)
#endregion

#region Internal functions
func _on_game_start() -> void:
	update_map()
	update_poisoned()
	update_visuals()

func update_map() -> void:
	map = []
	for y in range(map_size.y):
		var row := []
		row.resize(map_size.x)
		row.fill(TileType.STEAK_GOOD)
		map.append(row)

func update_poisoned() -> void:
	clean_steaks.clear()
	for y in range(map_size.y):
		for x in range(map_size.x):
			clean_steaks.append(Vector2i(x, y))
	
	clean_steaks.shuffle()
	for i in range(num_poisoned):
		var p = clean_steaks.pop_front()
		set_tile(p, TileType.STEAK_BAD)
func update_visuals() -> void:
	visual_tiles.clear()
	grid_container.columns = map_size.x
	for n in grid_container.get_children():
		grid_container.remove_child(n)
		n.queue_free() 
	
	for y in range(map_size.y - 1, -1, -1):
		for x in range(map_size.x):
			var pos = Vector2i(x, y)
			var tile = get_tile_type(pos)
			var empty = Button.new()
			empty.size_flags_horizontal = Control.SIZE_FILL
			empty.size_flags_vertical = Control.SIZE_FILL
			var scene: Tile
			if tile != TileType.EMPTY:
				scene = STEAK_TILE.instantiate() as SteakTile
				if not Engine.is_editor_hint(): 
					scene.steak_pressed.connect(_on_steak_selected)
					scene.tree_exiting.connect(func():
						scene.steak_pressed.disconnect(_on_steak_selected)
					)
			else: 
				scene = EMPTY_TILE.instantiate()
			scene.set_right(is_right)
			grid_container.add_child(scene)
			visual_tiles.append(scene)
			queue_redraw()
	#var len = tiles.size()
	#for i in range(len):
		#var y = roundi(float(i) / map_size.y)
		#var x = i % map_size.y
		#var 
func _get_grid_position(idx: int) -> Vector2i:
	if idx == -1:
		push_error("Idx for grid position in GameContainer was not found, returning 0")
		return Vector2i.ZERO
	var x : int = idx % map_size.x
	var y : int = map_size.y - 1 - floori(float(idx) / float(map_size.x))
	return Vector2i(x, y)
func _clamp_pos(v:Vector2i) -> Vector2i:
	v.x = clampi(v.x, 0, map_size.x-1)
	v.y = clampi(v.y, 0, map_size.y-1)
	return v
#endregion


#region external api
func get_num_poisoned() -> int:
	var count := 0
	for row in map:
		for tile in row:
			if tile == TileType.STEAK_BAD:
				count += 1
	return count
func get_random_position() -> Vector2i:
	return Vector2i(
		randi_range(0, map_size.x-1),
		randi_range(0, map_size.y-1)
	)

## Sets the tile, updates clean_steaks, and updates visuals
func set_tile(pos: Vector2i, tile: TileType) -> void:
	pos = _clamp_pos(pos)
	if tile == map[pos.y][pos.x]: return
	if tile == TileType.STEAK_GOOD:
		if clean_steaks.has(pos):
			clean_steaks.append(pos)
	else:
		clean_steaks.erase(pos)
	map[pos.y][pos.x] = tile
	update_visuals()

func get_tile_type(pos: Vector2i) -> TileType:
	pos = _clamp_pos(pos)
	return map[pos.y][pos.x]

func flip_tile(pos: Vector2i) -> void:
	pos = _clamp_pos(pos)
	var t = get_tile_type(pos)
	var new_t = TileType.EMPTY
	if t == TileType.STEAK_GOOD:
		new_t = TileType.STEAK_BAD
	elif t == TileType.STEAK_BAD:
		new_t = TileType.STEAK_GOOD
	set_tile(pos, new_t)

## Empties steak position and returns the position
func eat_steak(pos: Vector2i) -> TileType:
	pos = _clamp_pos(pos)
	var out = get_tile_type(pos)
	set_tile(pos, TileType.EMPTY)
	if out != TileType.EMPTY:
		steaks_eaten_this_round += 1
	return out
#endregion
