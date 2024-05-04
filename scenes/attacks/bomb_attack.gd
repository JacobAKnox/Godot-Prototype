extends Attack

func setup(_attack_dir: Vector2, _vel: Vector2):
	$Node/DamageBox.position = to_global(position)
	$Node/Polygon2D.position = to_global(position)

func _on_timer_timeout():
	cooldown_over.emit()
	end_attack()
