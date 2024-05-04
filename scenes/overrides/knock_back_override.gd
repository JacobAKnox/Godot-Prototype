class_name KnockbackOverride
extends MovementOverride

@export var KNOCKBACK_VEL: int = 600

var knocked_back = false

func process(_delta, player: Player, direction: Vector2):
	if knocked_back:
		return
	player.velocity = direction.normalized() * KNOCKBACK_VEL
	knocked_back = true
