extends CanvasLayer

func update_health(health: int):
	for i in $MarginContainer/VBoxContainer/HBoxContainer.get_child_count():
		if i > health:
			$MarginContainer/VBoxContainer/HBoxContainer.get_child(i).visible = false
		else:
			$MarginContainer/VBoxContainer/HBoxContainer.get_child(i).visible = true
			
func update_state(on_floor, on_ceil, on_wall):
	$MarginContainer/VBoxContainer/State.text = " Floor: %s \n Ceil: %s \n Wall: %s" % [on_floor, on_ceil, on_wall]
