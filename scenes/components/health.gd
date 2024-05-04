class_name Health
extends Node

@export var MAX_HEALTH := 1
@export var INVINICBLE_SEC := 1.0
@export var PERMANANTLY_INVINCIBLE := false

@onready
var health = MAX_HEALTH
var invincible = false

signal died
signal damage_applied

func apply_damage(damage: int):
	if not invincible and not PERMANANTLY_INVINCIBLE:
		health -= damage
		call_deferred("make_invincible")
	damage_applied.emit()
	if health <= 0:
		die()

func die():
	died.emit()
	
func make_invincible():
	invincible = true
	$InvincibleTimer.start(INVINICBLE_SEC)
	
func reset_health():
	health = MAX_HEALTH

func _on_invincible_timer_timeout() -> void:
	invincible = false
