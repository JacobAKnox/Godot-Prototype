extends PlatformerEntity

@export var SPEED: float = 0
@export var GRAVITY: float = 0
@export var MAX_BOUNCES: int = 0
@export var DAMAGE: int = 1
@export var MAX_COLLISIONS: int = 1

var bounces = 0
var alive = true
var on_floor = false

signal expired

func setup(direction: Vector2, vel: Vector2):
	velocity = SPEED * direction + vel
	
func _physics_process(delta):
	if not alive:
		expire()
		return
		
	collide(delta)
		
	if bounces >= MAX_BOUNCES:
		expire()
		
func collide(delta):
	var collision = move_and_collide(velocity * delta)
	var collisions = 0
	
	for i in range(MAX_COLLISIONS):
		if not collision:
			break
			
		velocity = velocity.bounce(collision.get_normal())
		if collision.get_normal().y > 0:
			on_floor = true
			
		bounces += 1
		var groups = collision.get_collider().get_groups()
		alive = groups.has("terrain")
			
		collision = move_and_collide(velocity * delta)
		collisions = i
	
	if collisions >= MAX_COLLISIONS:
		expire()
		
func expire(_dir := Vector2.ZERO):
	expired.emit()
	queue_free()
