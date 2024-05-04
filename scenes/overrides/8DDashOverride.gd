extends MovementOverride

@export var dash_speed: float = 650
var inital_direction: Vector2 = Vector2.ZERO

func process(_delta, player: Player, direction: Vector2):
	if inital_direction == Vector2.ZERO:
		inital_direction = direction
	player.velocity = inital_direction * dash_speed
