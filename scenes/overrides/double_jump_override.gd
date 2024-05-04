extends MovementOverride

@export var JUMP_VELOCITY: float = 600

func process(_delta, player: Player, _direction: Vector2):
	player.velocity.y = -JUMP_VELOCITY
	over.emit()
