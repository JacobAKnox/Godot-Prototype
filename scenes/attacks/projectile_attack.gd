extends Attack

@export var offset: float
@export var projectile: PackedScene

func setup(attack_dir: Vector2, vel: Vector2):
	super.setup(attack_dir, vel)
	position += offset * attack_dir
	var proj = projectile.instantiate()
	proj.position = self.global_position
	proj.expired.connect(end_attack)
	proj.setup(attack_dir, vel)
	Config.get_game().add_entity(proj)

func end_attack():
	attack_over.emit()

func _on_timer_timeout():
	cooldown_over.emit()
	queue_free()
