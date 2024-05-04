class_name Attack
extends Node2D

var attack_direction

signal attack_over
signal cooldown_over
signal hit(normal: Vector2)

func setup(attack_dir: Vector2, _vel: Vector2):
	attack_direction = attack_dir
	
func end_attack():
	attack_over.emit()
	queue_free()
	
func connect_hit(_callback: Callable):
	pass
