class_name Player
extends CharacterBody2D
#move
@export_range(0, 1000) var MAX_SPEED: float
@export_range(0, 5000) var GROUND_ACCELERATION: float
@export_range(0, 5000) var GROUND_DRAG: float
@export_range(0, 1000) var ATTACK_KNOCKBACK_VELOCITY: float

#dash
@export_range(0, 30) var DASH_LENGTH: int
@export_range(0, 10) var DASH_COOLDOWN_SEC: float
@export_range(0, 1000) var DASH_SPEED: float

#basic
@export_range(0, 0.1) var EPSILON: float
@export var BASE_COLOR: Color
@export var INVINICIBLE_COLOR: Color

#aiming
@export_range(0, 48) var RETICLE_DISTANCE: float = 24

#dash
var dash_frames: int = 0
var dashing: bool = false
var dash_charged: bool = true
var dash_dir: Vector2 = Vector2.ZERO

#basic
var air_frames: int = 0
var facing := Vector2.ZERO

#move
var attacking: bool = false
var attack_knockback: Vector2 = Vector2.ZERO

#aiming
var aim_dir: Vector2 = Vector2.UP

var override: MovementOverride = null

signal respawn

func _ready():
	$HPHud.update_health($Health.health)
	$Polygon2D.color = BASE_COLOR

func _physics_process(delta):
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if override != null:
		override.process(delta, self, facing if direction.is_zero_approx() else direction)
		if override != null and not override.cancelable: 
			process_end()
			return
	
	if !direction.is_zero_approx():
		facing = direction
	
	var accel = GROUND_DRAG if abs(direction.length_squared()) < EPSILON else GROUND_ACCELERATION
	
	#attack knockback
	velocity += attack_knockback * ATTACK_KNOCKBACK_VELOCITY
	attack_knockback = Vector2.ZERO
	
	# dash
	if Input.is_action_just_pressed("dash") and dash_charged:
		dashing = true
		dash_charged = false
		dash_dir = direction
		get_tree().create_timer(DASH_COOLDOWN_SEC).timeout.connect(func(): dash_charged = true)
		remove_override()
	
	# outside loop
	velocity = velocity.move_toward(direction * MAX_SPEED, accel * delta)
	
	if dashing:
		dash_frames += 1
		if dash_frames >= DASH_LENGTH:
			dashing = false
			dash_frames = 0
		velocity = DASH_SPEED * dash_dir
	
	process_end()
	
func process_end() -> void:
	move_and_slide()
	$HPHud.update_state(is_on_floor(), is_on_ceiling(), is_on_wall())
	update_animation()
	update_reticle()
	$CompassUI.update_angle(global_position)
	
func update_reticle() -> void:
	var mouse_move = Input.get_last_mouse_velocity()
	var aim_input = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
	
	if mouse_move.is_zero_approx() and aim_input.is_zero_approx():
		pass
	elif mouse_move.is_zero_approx():
		aim_dir = aim_dir if aim_input.is_zero_approx() else aim_input.normalized()
	else:
		aim_dir = global_position.direction_to(get_global_mouse_position())

	$Aim.rotation = aim_dir.angle()
	
func update_animation():
	if $Health.invincible:
		$Polygon2D.color = INVINICIBLE_COLOR
	else:
		$Polygon2D.color = BASE_COLOR
	
func _input(event):
	if not attacking and event.is_action_pressed("attack"):
		spawn_attack(preload("res://scenes/attacks/basic_attack.tscn"))
	if not attacking and event.is_action_pressed("discard"):
		handle_card($Deck.get_attack())
	if event.is_action_pressed("inventory") and not MenuManager.is_menu_loaded():
		MenuManager.load_menu(MenuLevel.INVENTORY, false, $Deck.get_all_cards())
		get_tree().paused = true
	
func handle_card(card):
	if card == null:
		return
	
	activate_override(card[1])
	spawn_attack(card[0])

func activate_override(override_scene: PackedScene):
	if not can_override() or override_scene == null:
		return
	remove_override()
	add_override(override_scene)

func spawn_attack(attack_scene: PackedScene):
	if attack_scene == null:
		return
	attacking = true
	var attackNode = attack_scene.instantiate()
	attackNode.position = $AttackSpawn.position
	attackNode.attack_over.connect(func(): pass)
	attackNode.cooldown_over.connect(func(): attacking = false)
	attackNode.connect_hit(handle_attack_knockback)
	add_child(attackNode)
	attackNode.setup(aim_dir, velocity)
	
func handle_attack_knockback(hit_direction: Vector2):
	if attack_knockback.is_zero_approx():
		attack_knockback = -hit_direction

@export var knockback_override: PackedScene
func handle_knockback(hit_from: Vector2):
	if not can_override():
		return
	remove_override()
	add_override(knockback_override)
	override.process(0, self, hit_from)
	
func can_override():
	return override == null or override.cancelable

func remove_override():
	if override == null:
		return
	override.queue_free()
	override = null
	$OverrideTimer.stop()
	
func add_override(new: PackedScene):
	override = new.instantiate()
	override.connect("over", handle_override_over)
	add_child(override)
	$OverrideTimer.start(override.time)
	
func handle_override_over():
	remove_override()

func update_camera_bounds(limts: Rect2, size: Vector2):
	$Camera2D.limit_left = limts.position.x * size.x
	$Camera2D.limit_top = limts.position.y * size.y
	$Camera2D.limit_right = limts.end.x * size.x
	$Camera2D.limit_bottom = limts.end.y * size.y

func damage_applied():
	$HPHud.update_health($Health.health)
	
func die():
	respawn.emit()
	$Health.reset_health()
	$HPHud.update_health($Health.health)

func _on_body_body_entered(body):
	if not body.get_groups().has("hazard"):
		return
	var dir = -velocity.normalized()
	dir *= Vector2(randf(), randf())
	$RespawnTimer.start()

	handle_knockback(dir.normalized())
	
func _on_hit_box_area_entered(area: Area2D) -> void:
	if $Health.invincible or area.get_groups().has("aoe_hazard"):
		return
	var dir = -(area.global_position - position).normalized()
	dir.y = -randf()
	handle_knockback(dir.normalized())
	
func teleport(pos: Vector2):
	position = pos
	velocity = Vector2.ZERO

func stop_override():
	$OverrideTimer.stop()
	override = null

# respawns the player to a safe area when they hit a hazard
func _on_respawn_timer_timeout():
	respawn.emit()

func _on_override_timer_timeout():
	remove_override()
	
func set_goal(goal: Node2D) -> void:
	$CompassUI.set_goal(goal)

func get_deck() -> Deck:
	return $Deck
