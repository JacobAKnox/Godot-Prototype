extends PlatformerEntity

@export var PATROL_LENGTH := 0.0
@export var PATROL_SPEED := 100.0
@export var CHASE_SPEED := 100.0

@onready
var start_pos := position

var facing := -1

func _ready() -> void:
	update_last_dir(-1)

func _on_health_died() -> void:
	queue_free()

func _on_hit_box_hazard(_dir) -> void:
	queue_free()

func _on_state_machine_player_updated(state) -> void:
	if state == 'Chase':
		chase_update()
	update_state_params(state)
	
func update_state_params(state: String):
	if (position - start_pos).length() > PATROL_LENGTH and $TurnDelay.is_stopped():
		turn()
	if (is_on_wall() or on_edge()) and $TurnDelay.is_stopped():
		turn()
	if (position - start_pos).length() < PATROL_LENGTH and state == "Return":
		$FSM.trigger("in_patrol")
		$TurnDelay.start()
		update_last_dir(velocity.x/(abs(velocity.x)))
		
func on_edge():
	return (not $RightFloorRay.is_colliding()) or (not $LeftFloorRay.is_colliding())

func update_last_dir(new_dir: float) -> void:
	facing = new_dir as int
	$FSM.set_param("last_left", new_dir < 0)
	$FSM.set_param("last_right", new_dir > 0)

func can_move(dir: float) -> bool:
	if dir < 0:
		return $LeftFloorRay.is_colliding()
	else:
		return $RightFloorRay.is_colliding()

func turn():
	$FSM.trigger("patrol_turn")
	$TurnDelay.start()

func start_chase():
	$FSM.trigger("startle_over")
	
func animation_over():
	$FSM.trigger("anim_over")
	
func attack():
	$AnimationPlayer.play("attack")
	
func show_sword():
	$Attack.move(global_position, facing)
	$Attack.enable()
	
func hide_sword():
	$Attack.disable()

func _on_fsm_transited(to, _from) -> void:
	match to:
		"Left": 
			velocity.x = -PATROL_SPEED; update_last_dir(-1)
		"Right": 
			velocity.x = PATROL_SPEED; update_last_dir(1)
		"Startle": velocity.x = 0; $AnimationPlayer.play("startle")
		"Chase": chase_update()
		"Attack": velocity.x = 0; attack()
		"Return": velocity.x = PATROL_SPEED * get_dir(start_pos)
		
func chase_update():
	var player_dir = get_dir(Config.get_game().get_player().position)
	velocity.x = CHASE_SPEED * player_dir
	if not can_move(velocity.x):
		velocity.x = 0 
	update_last_dir(player_dir)
		
func get_dir(toward: Vector2) -> float:
	var dir = toward.x - global_position.x
	dir /= abs(dir)
	return dir

func _on_player_chase_player_near() -> void:
	$FSM.set_param("player_near", true)
	$FSM.set_param("player_far", false)

func _on_player_chase_player_far() -> void:
	$FSM.set_param("player_near", false)
	$FSM.set_param("player_far", true)

func _on_attack_range_player_near() -> void:
	$FSM.set_param("attack_range", true)

func _on_attack_range_player_far() -> void:
	$FSM.set_param("attack_range", false)
