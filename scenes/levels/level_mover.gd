extends Area2D

@export var target_level: String 

var can_enter = false

func _input(event):
	if can_enter and event.is_action_pressed("move_up"):
		Config.get_game().load_level(target_level)

func _on_body_entered(body):
	if body.get_groups().has("player"):
		$ActionIcon.show()
		can_enter = true

func _on_body_exited(body):
	if body.get_groups().has("player"):
		$ActionIcon.hide()
		can_enter = false
