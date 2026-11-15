@tool
extends AspectRatioContainer
class_name GameContainer

enum TileType {
	EMPTY,
	STEAK_GOOD,
	STEAK_BAD,
}

## x, y size
@export var tilemap : TileMapLayer
@export var map_size := Vector2i(5, 4)
@export var margin_bottom : int = 100
@export var margin_sides : int = 100
@export var num_poisoned := 8
@export_tool_button("Update Tilemap") var update_tilemap_button = update_tilemap_action
var map : Array[Array] 
## Randomized queue of clean steaks
var clean_steaks : Array[Vector2i]
var atlas_coords : Dictionary[TileType, Vector2i] = {
	TileType.EMPTY: Vector2i(0,0),
	TileType.STEAK_GOOD: Vector2i(0,0),
	TileType.STEAK_BAD: Vector2i(0,0),
}

func _ready() -> void:
	SignalBus.game_start.connect(_on_game_start)
	_on_game_start()
	
#region Internal functions
func _on_game_start() -> void:
	update_map()
	update_poisoned()
	update_tilemap()

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
func update_tilemap() -> void:
	var container_size := tilemap.get_viewport_rect().size
	tilemap.position = Vector2(
		margin_sides, 
		container_size.y - margin_bottom
	)
	tilemap.tile_set.tile_size = Vector2(
		(container_size.x - 2*margin_sides) / map_size.x,
		150
	)
	tilemap.clear()
	for y in range(map_size.y):
		for x in range(map_size.x):
			var pos = Vector2i(x, y)
			var tile = get_tile(pos)
			set_tilemap_visual(pos, tile)
func update_tilemap_action() -> void:
	_on_game_start()

func _clamp_pos(v:Vector2i) -> Vector2i:
	v.x = clampi(v.x, 0, map_size.x-1)
	v.y = clampi(v.y, 0, map_size.y-1)
	return v
#endregion

#region Interaction with the tilemaplayer
func to_tilemap_pos(pos: Vector2i) -> Vector2i:
	pos = _clamp_pos(pos)
	pos.y = -1 - pos.y
	return pos

func set_tilemap_visual(pos: Vector2i, tile: TileType) -> void:
	var tilemap_pos = to_tilemap_pos(pos) 
	if tile == TileType.EMPTY:
		tilemap.erase_cell(tilemap_pos)
	else:
		tilemap.set_cell(tilemap_pos, 1, Vector2i(0, 0), 1)
		tilemap.update_internals()
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
	update_tilemap()

func get_tile(pos: Vector2i) -> TileType:
	pos = _clamp_pos(pos)
	return map[pos.y][pos.x]

func flip_tile(pos: Vector2i) -> void:
	pos = _clamp_pos(pos)
	var t = get_tile(pos)
	var new_t = TileType.EMPTY
	if t == TileType.STEAK_GOOD:
		new_t = TileType.STEAK_BAD
	elif t == TileType.STEAK_GOOD:
		new_t = TileType.STEAK_GOOD
	set_tile(pos, new_t)
	update_tilemap()

## Empties steak position and returns the position
func eat_steak(pos: Vector2i) -> TileType:
	pos = _clamp_pos(pos)
	var out = get_tile(pos)
	set_tile(pos, TileType.EMPTY)
	update_tilemap()
	return out
#endregion

#func _input(event: InputEvent) -> void:
	#if OS.is_debug_build() and event.is_action_pressed("1"):
		#var p = get_random_position()
		#eat_steak(p)
