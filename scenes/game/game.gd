extends AspectRatioContainer
class_name GameContainer

enum TileType {
	EMPTY,
	STEAK_GOOD,
	STEAK_BAD,
}
const STEAK_TILE = preload("res://scenes/tiles/steak_tile.tscn")
const EMPTY_TILE = preload("res://scenes/tiles/empty_tile.tscn")
@export var subviewport: SubViewport
@export var game_subviewport_container: SubViewportContainer
@export var spotlight: Node2D
## x, y size
@export var grid_container : GridContainer
@export var map_size := Vector2i(5, 4)
@export var margin_bottom : int = 100
@export var margin_sides : int = 100
@export var num_poisoned := 8
@export var spotlight_offset := Vector2i(0,0)
@export var is_right := false
var map : Array[Array] 
## Randomized queue of clean steaks
var clean_steaks : Array[Vector2i]
var visual_tiles: Array[Control] = []

func _ready() -> void:
	spotlight.hide()
	SignalBus.game_start.connect(_on_game_start)
	subviewport.gui_focus_changed.connect(_on_focus_changed)
	get_viewport().gui_focus_changed.connect(func(node: Control): 
		if node != game_subviewport_container and node != self: 
			spotlight.hide()
			return
		spotlight.show()
		_grab_first_focus()
	)
	_on_game_start()

#region Focus stuff
func _grab_first_focus(skip_empty_tiles: bool=true) -> void:
	for tile in visual_tiles:
		if skip_empty_tiles:
			var idx = visual_tiles.find(tile)
			var pos = _get_grid_position(idx)
			if get_tile_type(pos) == TileType.EMPTY:
				continue
		tile.grab_focus()
		return
func _on_focus_changed(node: Control) -> void:
	var idx = visual_tiles.find(node)
	if idx == -1: return
	var length = visual_tiles.size()
	# adding row length to move down a row
	# if outside bounds, set to itself (ignoring other ui for now)
	var bottom_neighbor_idx = idx + map_size.x 
	if bottom_neighbor_idx < length:
		var target = visual_tiles[bottom_neighbor_idx]
		node.focus_neighbor_bottom = node.get_path_to(target)
	else:
		node.focus_neighbor_bottom = "."
	var top_neighbor_idx = idx - map_size.x 
	if top_neighbor_idx >= 0:
		var target = visual_tiles[top_neighbor_idx]
		node.focus_neighbor_top = node.get_path_to(target)
	
	# highlight
	spotlight.global_position = node.global_position + node.size * 0.5
	var spotlight_target := Vector2i.ZERO
	if is_right:
		spotlight_target = Vector2i(
			subviewport.size.x - spotlight_offset.x, 
			spotlight_offset.y
		)
	else:
		spotlight_target = spotlight_offset
	spotlight.look_at(spotlight_target)
	spotlight.rotate(PI/2)
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
			var scene = STEAK_TILE.instantiate() if tile != TileType.EMPTY else EMPTY_TILE.instantiate()
			grid_container.add_child(scene)
			visual_tiles.append(scene)
	#var len = tiles.size()
	#for i in range(len):
		#var y = roundi(float(i) / map_size.y)
		#var x = i % map_size.y
		#var 
func _get_grid_position(idx: int) -> Vector2i:
	var x : int = idx % map_size.x
	var y : int = map_size.y - 1 - roundi(float(idx) / float(map_size.x))
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
		randi_range(0, map_size.x),
		randi_range(0, map_size.y)
	)

func set_tile(pos: Vector2i, tile: TileType) -> void:
	pos = _clamp_pos(pos)
	if tile == map[pos.y][pos.x]: return
	if tile == TileType.STEAK_GOOD and \
			clean_steaks.find(pos) == -1:
		clean_steaks.append(tile)
		clean_steaks.shuffle()
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
	elif t == TileType.STEAK_GOOD:
		new_t = TileType.STEAK_GOOD
	set_tile(pos, new_t)
	update_visuals()

## Empties steak position and returns the position
func eat_steak(pos: Vector2i) -> TileType:
	pos = _clamp_pos(pos)
	var out = get_tile_type(pos)
	set_tile(pos, TileType.EMPTY)
	return out
#endregion

func _input(event: InputEvent) -> void:
	if OS.is_debug_build() and event.is_action_pressed("1"):
		var p = get_random_position()
		eat_steak(Vector2i(0,4))
