extends CanvasLayer

var goal: Node2D = null

const SNAP_POINTS := 16
const X: float = PI / (SNAP_POINTS/2.0)

var progress_value := 0.0
var can_start := true

func _physics_process(_delta: float) -> void:
	var timer := $CollectionDelay
	
	if not Input.get_vector("move_left", "move_right", "move_up", "move_down").is_zero_approx():
		timer.stop()
		progress_value = 0
		can_start = true
		
	if not timer.is_stopped():
		progress_value = 1.0 - (timer.time_left/timer.wait_time)
	
	$Compass/ProgressBar.value = progress_value

func set_goal(g: Node2D) -> void:
	goal = g
	
func update_angle(player_pos: Vector2) -> void:
	var dir = player_pos.direction_to(goal.global_position)
	$Compass/Needle.rotation = X * (round(dir.angle() / X) as float)

func _input(event: InputEvent) -> void:
	var timer_stopped = $CollectionDelay.is_stopped()
	if timer_stopped and can_start and event.is_action_pressed("pickup"):
		$CollectionDelay.start()
		can_start = false
		progress_value = 0
	if event.is_action_released("pickup"):
		$CollectionDelay.stop()
		can_start = true
		progress_value = 0

func _on_collection_delay_timeout() -> void:
	if goal.try_collect():
		$Compass.hide()
		$Key.show()
	progress_value = 1
