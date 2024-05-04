class_name Seperator
extends Area2D

@export_range(0, 1) var AVOID_FACTOR := 1.0

func get_avoid_vec() -> Vector2:
	return (get_overlapping_bodies()
	.filter(func(b: Node2D): return b.get_groups().has("boid"))
	.reduce(func(accum: Vector2, b: Node2D): return accum + (global_position - b.global_position), Vector2.ZERO)) * AVOID_FACTOR
