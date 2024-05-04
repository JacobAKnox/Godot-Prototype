extends Node


func pick_random_goal(goal: Node2D) -> void:
	var loc_marker: Marker2D = get_children()[randi() % get_children().size()]
	goal.position = loc_marker.global_position
