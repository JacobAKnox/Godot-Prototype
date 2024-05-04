class_name CheckPoint
extends Area2D

signal checkpoint(spawnpoint)

@export var respawn: Marker2D

func _on_body_entered(body):
	if body.get_groups().has("player"):
		checkpoint.emit(respawn)
