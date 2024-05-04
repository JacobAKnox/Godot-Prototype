class_name MovementOverride
extends Node

signal over

@export var time: float = 1
@export var cancelable: bool = false
	
func process(_delta, player: Player, _direction: Vector2):
	player.velocity = Vector2.ZERO
