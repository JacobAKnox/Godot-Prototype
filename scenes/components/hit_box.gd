class_name HitBox
extends Area2D

signal damage_taken(amount: int)
signal hazard(dir: Vector2)

func apply_damage(amount: int) -> void:
	damage_taken.emit(amount)

func _on_body_entered(body: Node2D) -> void:
	if body.get_groups().has("hazard"):
		apply_damage(1)
		hazard.emit(-(body.position - position).normalized())
