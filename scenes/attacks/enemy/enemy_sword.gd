class_name EnemyAttack
extends Polygon2D

@export var OFFSET := Vector2.ZERO

func move(_base: Vector2, dir: float) -> void:
	position = (dir * OFFSET) 
	scale.x = dir
	
func enable() -> void:
	show()
	$DamageBox/CollisionShape2D.disabled = false
	
func disable() -> void:
	hide()
	$DamageBox/CollisionShape2D.disabled = true
