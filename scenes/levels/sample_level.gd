extends Level
	
func get_limits():
	return $Terrain.get_used_rect()

func get_tile_size():
	return $Terrain.tile_set.tile_size
