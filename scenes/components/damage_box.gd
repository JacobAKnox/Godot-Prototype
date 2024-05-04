class_name DamageBox
extends Area2D

@export var damage := 0
@export var dir := Vector2.ZERO

signal hit(direction: Vector2)

func _on_area_entered(area: Area2D) -> void:
	if area is HitBox:
		area.apply_damage(damage)
		hit.emit(dir)

func _on_body_entered(body: Node2D) -> void:
	if body.get_groups().has("damageable"):
		hit.emit(dir)
