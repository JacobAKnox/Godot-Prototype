extends Node

var current_level: Level = null
var player: Player = null
var running = false

@export var debug_seed: int = -1

func start_game():
	if debug_seed == -1:
		randomize()
	else:
		seed(debug_seed)
	MenuManager.load_menu(MenuLevel.NONE)
	add_level()
	add_player()
	running = true
	
func add_level():
	current_level = preload("res://scenes/levels/cave_level.tscn").instantiate()
	$pausable.add_child(current_level)
	
func add_entity(entity: Node):
	$pausable.add_child(entity)
	
func load_level(new_level: String):
	var level = load(new_level).instantiate()
	current_level.queue_free()
	current_level = level
	$pausable.add_child(level)
	player.teleport(level.get_player_spawn())
	player.update_camera_bounds(level.get_limits(), current_level.get_tile_size())
	
func add_player():
	player = preload("res://scenes/player/player.tscn").instantiate()
	$pausable.add_child(player)
	player.set_goal(current_level.get_goal())
	player.respawn.connect(on_player_respawn)
	player.update_camera_bounds(current_level.get_limits(), current_level.get_tile_size())
	player.teleport(current_level.get_player_spawn())
	
func get_player():
	return player
	
func on_player_respawn():
	player.teleport(current_level.get_player_spawn())

func _process(_delta):
	if not MenuManager.is_menu_loaded():
		get_tree().paused = false
	
func pause():
	get_tree().paused = true
	MenuManager.load_menu(MenuLevel.PAUSE, false)
	
func _input(event):
	var paused = false
	
	if event.is_action("quick_quit"):
		quit()
	if event.is_action_pressed("pause") and running and not get_tree().paused and not MenuManager.is_menu_loaded():
		pause()
	elif event.is_action_pressed("ui_cancel") and MenuManager.is_menu_loaded() and (running or MenuManager.is_previous_menu()):
		MenuManager.load_last_menu()
		
func quit_title():
	MenuManager.load_menu(MenuLevel.NONE)
	current_level.queue_free()
	current_level = null
	player.queue_free()
	player = null
	running = false
	MenuManager.load_menu(MenuLevel.MAIN)

func quit():
	get_tree().quit()
