extends Node

var inputs_file = "user://user_remap.tres"

func get_game():
	return get_tree().root.find_child("Game", false, false)
