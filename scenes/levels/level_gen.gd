extends Level

@export var grid_size: Vector2i = Vector2i.ZERO
var pattern_size

var start_room = Vector2i.ZERO
var end_room = Vector2i.ZERO

var astar: AStar2D = AStar2D.new()
var weights: Array[int] = []
var rooms: Array[int] = []

var side_queue: Array[TilePlacement] = []

@onready
var tile_map = $Terrain

var directions = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
var dir_flags = [RoomEditor.FLAGS.N, RoomEditor.FLAGS.S, RoomEditor.FLAGS.E, RoomEditor.FLAGS.W]

var anti_mask = RoomEditor.FLAGS.START | RoomEditor.FLAGS.END

func _ready():
	pattern_size = tile_map.tile_set.get_pattern(0).get_size()
	run_build()
	
func _input(event):
	if event.is_action_pressed("debug"):
		run_build()
		
func run_build():
	astar.clear()
	weights.clear()
	populate_grid()
	connect_grid()
	build_crit_path()
	place_side_rooms()
	build_level()
	post_process()
	
func populate_grid():
	for i in grid_size.x * grid_size.y:
		var weight = randi_range(0, 10)
		weights.append(weight)
		astar.add_point(i, index_to_loc(i), weight)
	assert(weights.size() == grid_size.x * grid_size.y, "Did not create enough weights")
	
func connect_grid():
	var count = 0
	for i in weights.size():
		for item in get_adjcent_sopts(i):
			astar.connect_points(i, item)
			count += 1
	var w = grid_size.x
	var h = grid_size.y
	assert(count == (((w-1)*h)+((h-1)*w))*2, "Not enough connections made")
	
func get_adjcent_sopts(index):
	var loc = index_to_loc(index)
	return directions.filter(func(v): 
		return loc_in_range(loc + v)
	).map(func(v): 
		return loc_to_index(v + loc))

func build_crit_path():
	start_room.y = randi_range(0, grid_size.y-1)
	end_room = Vector2i(grid_size.x-1, randi_range(0, grid_size.y-1))
	var path: Array = astar.get_id_path(loc_to_index(start_room), loc_to_index(end_room))

	rooms.resize(weights.size())
	rooms.fill(-1)
	var mask = RoomEditor.FLAGS.START
	var anti = 0
	var next_room_vec = Vector2i.ZERO
	var last_mask = RoomEditor.FLAGS.START
	
	while path.size() > 1:
		next_room_vec = get_relative_vec(path[0], path[1])
		assert(abs(next_room_vec.x) != abs(next_room_vec.y) and next_room_vec.length() == 1, "Rooms in path are not adjcent")
		mask |= RoomEditor.dir_to_flags(next_room_vec) # add the next room direction to the mask
		var room_data = RoomEditor.get_rooms(mask, anti | get_edge_anti_mask(path[0])).pick_random()
		rooms[path[0]] = room_data[0]
		queue_adjcent_rooms(path[0], room_data[1] & ~mask)
		mask &= ~last_mask # remove the old direction
		mask = RoomEditor.invert_connections(mask) # invert the connection for the next room
		last_mask = mask # keep it for removal later
		path.pop_front() # next room
		anti = anti_mask
	
	mask |= RoomEditor.FLAGS.END
	var room_data = RoomEditor.get_rooms(mask, 0).pick_random()
	rooms[path[0]] = room_data[0]
	queue_adjcent_rooms(path[0], room_data[1] & ~mask)
	
func queue_adjcent_rooms(loc, mask):
	for d in dir_flags:
		if mask & d:
			var new_loc = get_adjecnt_room(index_to_loc(loc), d)
			if loc_in_range(new_loc):
				new_loc = loc_to_index(new_loc)
			else:
				continue
			if rooms[new_loc] != -1:
				continue
			rooms[new_loc] = 0
			side_queue.append(TilePlacement.new(new_loc, RoomEditor.invert_connections(d)))
	
func place_side_rooms():
	while side_queue.size() > 0:
		var room: TilePlacement = side_queue.pop_front()
		var room_data = RoomEditor.get_rooms(room.mask, anti_mask | get_edge_anti_mask(room.location)).pick_random()
		rooms[room.location] = room_data[0]
		queue_adjcent_rooms(room.location, room_data[1] & ~room.mask)

func loc_in_range(loc: Vector2i):
	return loc.x < grid_size.x and loc.x >= 0 and loc.y < grid_size.y and loc.y >= 0
	
func loc_to_index(loc):
	assert(loc.x <= grid_size.x and loc.x >= 0, "Accessed location outside of grid")
	assert(loc.y <= grid_size.y and loc.y >= 0, "Accessed location outside of grid")
	return (loc.y * grid_size.x) + loc.x
	
func index_to_loc(index: int):
	assert(index < grid_size.x * grid_size.y, "Accessed index not in grid")
	return Vector2i(index % grid_size.x, index / grid_size.x)
	
func get_relative_vec(to, from):
	return index_to_loc(from) - index_to_loc(to)

func build_level():
	for r in rooms.size():
		if rooms[r] == -1:
			rooms[r] = RoomEditor.get_rooms(0, ~0).pick_random()[0]
		tile_map.set_pattern(0, pattern_size*index_to_loc(r), tile_map.tile_set.get_pattern(rooms[r]))
	
func post_process():
	for x in grid_size.x * pattern_size.x:
		for y in grid_size.y * pattern_size.y:
			var loc = Vector2i(x, y)
			var atlas_coords = tile_map.get_cell_atlas_coords(0, loc)
			if  atlas_coords == RoomEditor.spawn_tile:
				$PlayerSpawn.position = to_global(tile_map.map_to_local(loc))
				tile_map.erase_cell(0, loc)
			if atlas_coords == RoomEditor.enemy_tile:
				tile_map.erase_cell(0, loc)
				add_enemy(to_global(tile_map.map_to_local(loc)))
			if atlas_coords == RoomEditor.end_tile:
				tile_map.erase_cell(0, loc)
				add_exit(to_global(tile_map.map_to_local(loc)))
	
	BetterTerrain.update_terrain_area(tile_map, 0, Rect2i(Vector2i.ZERO, grid_size*pattern_size))

@export var enemy: PackedScene
func add_enemy(pos):
	var e: Node2D = enemy.instantiate()
	e.position = pos
	add_child(e)

@export_group("Exits")
@export var exit: PackedScene
@export var next_level: String
@export var offset: Vector2
func add_exit(pos):
	var e: Node2D = exit.instantiate()
	e.target_level = next_level
	e.position = pos + offset
	add_child(e)

func get_edge_anti_mask(index):
	var loc = index_to_loc(index)
	var dir = Vector2i.ZERO
	for d in directions.filter(func(v): return not loc_in_range(loc + v)):
		dir += d
	return RoomEditor.dir_to_flags(dir)
	
func get_adjecnt_room(postion: Vector2i, direction: int):
	var offset = Vector2i.ZERO
	match direction:
		RoomEditor.FLAGS.N:
			offset = Vector2i.UP
		RoomEditor.FLAGS.S:
			offset = Vector2i.DOWN
		RoomEditor.FLAGS.E:
			offset = Vector2i.RIGHT
		RoomEditor.FLAGS.W:
			offset = Vector2i.LEFT
	return postion + offset
	
class TilePlacement:
	extends RefCounted
	
	var location: int
	var mask: int
	
	func _init(loc, con):
		location = loc
		mask = con
