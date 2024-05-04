class_name BasicAttack
extends Attack

@export_range(0, 500) var OFFSET: int = 0

func setup(attack_dir: Vector2, vel: Vector2):
	super.setup(attack_dir, vel)
	position += attack_dir * OFFSET
	rotation = attack_dir.angle()
	$DamageBox.dir = attack_dir

func connect_hit(callback: Callable):
	$DamageBox.hit.connect(callback)

func _on_cooldown_over():
	cooldown_over.emit()
	end_attack()
