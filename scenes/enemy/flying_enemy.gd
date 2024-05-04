extends PlatformerEntity

@export var idle_speed := 300.0
@export var chase_speed := 500.0
@export var charge_speed := 700.0
@export var idle_distance := 100.0

@export_range(0, 1) var charge_chance := 0.3

@export_range(0, 1000) var max_wander := 500.0

var charge_dir := Vector2.ZERO

func _ready():
	$NavigationAgent2D.target_position = get_random_destination()
	
func _physics_process(_delta: float) -> void:
	pass
	
func get_random_destination() -> Vector2:
	var angle := randf_range(0, 2 * PI)
	var dist := randf_range(0, max_wander)
	return (Vector2.from_angle(angle) * dist) + global_position

func _on_fsm_on_update(state: String) -> void:
	if $Stunnable.stunned:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	update_state_params()
	var speed := 0.0
	
	match state:
		"Loop":
			speed = idle_speed
			if is_on_wall() or $NavigationAgent2D.is_navigation_finished():
				$NavigationAgent2D.target_position = get_random_destination()
		"Chase":
			speed = chase_speed
			$NavigationAgent2D.target_position = Config.get_game().get_player().position
		"Charge":
			velocity = charge_speed * charge_dir
			move_and_slide()
			return
			
	velocity = speed * (position.direction_to($NavigationAgent2D.get_next_path_position()))
	velocity += $Seperator.get_avoid_vec()
	move_and_slide()
	
func update_state_params():
	if $NavigationAgent2D.is_navigation_finished():
		$FSM.trigger("nav_finished")
	
func _on_fsm_on_transit(to: String, _from: String) -> void:
	match to: 
		"Charge":
			charge_dir = (Config.get_game().get_player().position - position).normalized()
			$ChargeDone.start()

func _on_health_died() -> void:
	queue_free()

func _on_hit_box_hazard(_dir) -> void:
	$Health.die()

func _on_player_dectector_player_far() -> void:
	$FSM.set_param("player_far", true)
	$FSM.set_param("player_near", false)

func _on_player_dectector_player_inside_update(player: Node2D) -> void:
	var cs = $FSM.current_state.name
	if cs == "Charge":
		return
	
	if !get_player_line_of_sight(player):
		$FSM.set_param("player_far", true)
		$FSM.set_param("player_near", false)
	else: 
		$FSM.set_param("player_far", false)
		$FSM.set_param("player_near", true)
		
func get_player_line_of_sight(player: Node2D) -> bool:
	var space_state = get_world_2d().direct_space_state
	# 66 is terrain and terrain damage
	var query = PhysicsRayQueryParameters2D.create(global_position, player.global_position, 66)
	return !space_state.intersect_ray(query) and true

func _on_charge_timer_timeout() -> void:
	var cs = $FSM.current_state.name
	if cs != "Chase" or not $ChargeRange.player_inside:
		return
	
	if randf() < charge_chance:
		$FSM.trigger("charge")

func _on_charge_done_timeout() -> void:
	$FSM.trigger("charge_done")

func _on_hit_box_damage_taken(_amount: int) -> void:
	$Stunnable.stun()
