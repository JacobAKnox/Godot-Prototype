class_name Level
extends Node2D

@onready
var current_spawn: Marker2D = $PlayerSpawn

func _ready():
	var world := get_world_2d()
	$Terrain.set_navigation_map(1, world.navigation_map)
	$GoalSpawns.pick_random_goal($Goal)
	$GoalSpawns.queue_free()

func get_player_spawn():
	return current_spawn.position
	
func get_goal() -> Node2D:
	return $Goal
	
func _on_check_point_checkpoint(spawnpoint):
	current_spawn = spawnpoint
	
func get_limits():
	return $Terrain.get_used_rect()

func get_tile_size():
	return $Terrain.tile_set.tile_size
