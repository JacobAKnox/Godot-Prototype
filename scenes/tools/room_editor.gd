extends Node

var tile_set: TileSet
var terminator_tile: Vector2i
var spawn_tile: Vector2i
@export var enemy_tile: Vector2i
@export var end_tile: Vector2i

@export var pattern_data: Array = []

@export var pattern_size: Vector2i
# first 4 meta bits are nsew in that order rest are unused
@export var meta_width: int = 1

@export var meta_name: String = "connections"

enum FLAGS {N=1, S=2, E=4, W=8, START=1024, END=512}

func _ready():
	terminator_tile = $Terrain.get_cell_atlas_coords(0, Vector2i(-1, -1))
	spawn_tile = $Terrain.get_cell_atlas_coords(0, Vector2i(-1, -2))
	tile_set = $Terrain.tile_set
	while tile_set.get_patterns_count() > 0:
		tile_set.remove_pattern(0)
	pattern_data = []
	update_patterns()
	$Terrain.queue_free()
	$Label.queue_free()
	
func get_rooms(mask, antimask=0):
	return pattern_data.filter(func(item):
		return item[1] & mask == mask and not item[1] & antimask != 0
	)
	
func update_patterns():
	tile_set = $Terrain.tile_set
	var row = 0
	var col = 0

	var pattern_rect = get_pattern_rect(row, col)
	var meta_rect = get_meta_rect(row, col)
	
	while not check_terminator(pattern_rect):
		while not check_terminator(pattern_rect):
			var pattern: TileMapPattern = $Terrain.get_pattern(0, get_cells_in_area(pattern_rect))
			var meta = read_meta(meta_rect)
			pattern.set_meta(meta_name, meta)
			pattern_data.append([pattern_data.size(), meta])
			tile_set.add_pattern(pattern)
	
			col += 1
			pattern_rect = get_pattern_rect(row, col)
			meta_rect = get_meta_rect(row, col)
		row += 1
		col = 0
		pattern_rect = get_pattern_rect(row, col)
		meta_rect = get_meta_rect(row, col)

func get_cells_in_area(area: Rect2i):
	var cells: Array[Vector2i] = []
	for y in range(area.position.y, area.end.y+1):
		for x in range(area.position.x, area.end.x+1):
			var loc = Vector2i(x, y)
			if $Terrain.get_cell_tile_data(0, loc) != null:
				cells.append(loc)
	return cells
	
func read_meta(area: Rect2i):
	var meta: int = 0
	var bit = 0
	for y in range(area.position.y, area.end.y+1):
		for x in range(area.position.x, area.end.x+1):
			var pos = int(pow(2, bit))
			meta |= pos * (0 if $Terrain.get_cell_tile_data(0, Vector2i(x, y)) == null else 1)
			bit += 1
	return meta
	
func check_terminator(area: Rect2i):
	return $Terrain.get_cell_atlas_coords(0, area.position) == terminator_tile

func get_pattern_rect(row, col):
	# added col is for metadata tiles
	return Rect2i(col * pattern_size.x + col * meta_width, row * pattern_size.y, pattern_size.x-1, pattern_size.y-1)
	
func get_meta_rect(row, col):
	return Rect2i((col+1) * pattern_size.x + col * meta_width, row * pattern_size.y, meta_width-1, pattern_size.y-1)
	
func get_flags_list(mask):
	return FLAGS.values().filter(func(item): return item & mask)
	
func invert_connections(mask):
	var new_connections = mask & ~(FLAGS.N | FLAGS.S | FLAGS.E | FLAGS.W)
	if mask & FLAGS.N:
		new_connections |= FLAGS.S
	if mask & FLAGS.S:
		new_connections |= FLAGS.N
	if mask & FLAGS.E:
		new_connections |= FLAGS.W
	if mask & FLAGS.W:
		new_connections |= FLAGS.E
	return new_connections
	
func dir_to_flags(dir: Vector2i):
	var mask = 0
	if dir.x > 0:
		mask |= FLAGS.E
	elif dir.x < 0:
		mask |= FLAGS.W
	if dir.y < 0:
		mask |= FLAGS.N
	elif dir.y > 0:
		mask |= FLAGS.S
	return mask
	
func flags_to_dir(flags: int):
	var dir = Vector2i.ZERO
	if flags & FLAGS.N:
		dir += Vector2i.UP
	if flags & FLAGS.S:
		dir += Vector2i.DOWN
	if flags & FLAGS.E:
		dir += Vector2i.RIGHT
	if flags & FLAGS.W:
		dir += Vector2i.LEFT
	return dir
