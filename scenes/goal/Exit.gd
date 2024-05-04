extends Node2D

var exit_open := false

func _input(event):
	if event.is_action_pressed("interact") and exit_open and $PlayerDectector.player_inside:
		Config.get_game().quit_title()

func open():
	exit_open = true
	$open.show()
	
func _on_player_dectector_player_near() -> void:
	if exit_open:
		$ActionIcon.show()

func _on_player_dectector_player_far() -> void:
	$ActionIcon.hide()
