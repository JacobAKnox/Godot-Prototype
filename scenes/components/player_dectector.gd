class_name PlayerDetector
extends Area2D

signal player_near
signal player_far
signal player_inside_update(player: Node2D)

var player_inside := false
var player: Node2D = null

func _physics_process(_delta: float) -> void:
	if player_inside:
		player_inside_update.emit(player)

func _on_body_entered(body: Node2D) -> void:
	if body.get_groups().has("player"):
		player_inside = true
		player = body
		player_near.emit()

func _on_body_exited(body: Node2D) -> void:
	if body.get_groups().has("player"):
		player_inside = false
		player = null
		player_far.emit()
