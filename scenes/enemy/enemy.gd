extends PlatformerEntity

@export_range(0, 500) var SPEED: float = 300
@export_enum("Left:-1", "Right:1") var direction = -1

var stunned = false

func _physics_process(delta):
	velocity.x = direction * SPEED
	
	if stunned:
		velocity.x = 0
	
	super._physics_process(delta)
	
	# flip when you hit a wall
	if is_on_wall():
		direction *= -1

func _on_death_detector_body_entered(_body):
	if _body == self:
		return
	$Health.die()

func _on_damage_applied():
	stunned = true
	$StunTimer.start()
 
func _on_stun_timer_timeout():
	stunned = false

func _on_health_died() -> void:
	queue_free()

func _on_hit_box_hazard(_dir) -> void:
	$Health.die()
