class_name AoeHazard
extends Area2D

@export var damage := 0
@export var damage_cooldown := 1.0

signal hit(direction: Vector2)

var contaned_entities := {}

func _physics_process(delta: float) -> void:
	for hitbox in contaned_entities.keys():
		if contaned_entities[hitbox] > damage_cooldown:
			(hitbox as HitBox).apply_damage(damage)
			contaned_entities[hitbox] = 0
		else:
			contaned_entities[hitbox] += delta

func _on_area_entered(area: Area2D) -> void:
	if not area is HitBox:
		return
	
	contaned_entities[area] = 0

func _on_area_exited(area: Area2D) -> void:
	contaned_entities.erase(area)
