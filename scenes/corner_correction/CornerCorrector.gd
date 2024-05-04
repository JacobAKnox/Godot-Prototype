class_name CornerCorrecter 
extends RayCast2D

signal move(offset: Vector2)

var offset: Vector2 = Vector2.ZERO

func _ready():
	offset = global_position.direction_to(to_global($CornerRay.position))
	
func corner_correct(velocity: Vector2):
	var direction: Vector2 = global_position.direction_to(to_global(target_position))
	self.force_raycast_update()
	if self.is_colliding() and abs(direction.angle_to(velocity)) < 0.3 and not velocity.is_zero_approx():
		$CornerRay.force_raycast_update()
		if not $CornerRay.is_colliding():
			while self.is_colliding():
				move.emit(offset)
				self.force_raycast_update()
