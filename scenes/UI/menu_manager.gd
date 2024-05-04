extends Node

var menus = {
	MenuLevel.MAIN : preload("res://scenes/UI/MainMenu.tscn").instantiate(), 
	MenuLevel.OPTIONS : preload("res://scenes/UI/options_menu.tscn").instantiate(),
	MenuLevel.PAUSE : preload("res://scenes/UI/pause_menu.tscn").instantiate(),
	MenuLevel.INVENTORY : preload("res://scenes/UI/deck_viewer.tscn").instantiate(),
	MenuLevel.PICKUP : preload("res://scenes/UI/card_pickup.tscn").instantiate()
}

var current_menu: MenuState = null
var menu_stack = []

func _ready():
	load_menu(MenuLevel.MAIN)
	pass

func load_menu(menulevel, show_backround = true, args = []):
	if menulevel == MenuLevel.NONE:
		remove_children($CanvasLayer)
		menu_stack = []
		current_menu = null
		$CanvasLayer/Backround.hide()
		return
	
	if show_backround:
		$CanvasLayer/Backround.show()
	else:
		$CanvasLayer/Backround.hide()

	var new_menu = menus[menulevel]
	if new_menu.has_method("arg_apply"):
		new_menu.arg_apply(args)
	
	remove_children($CanvasLayer)
	$CanvasLayer.add_child(new_menu)
	
	if current_menu != null:
		menu_stack.push_front(current_menu)
	current_menu = MenuState.new(menulevel, show_backround, args)
	
func load_last_menu():
	if menu_stack.is_empty():
		load_menu(MenuLevel.NONE)
		return
	var last_menu: MenuState = menu_stack.pop_front()
	load_menu(last_menu.type, last_menu.backround, last_menu.args)
	menu_stack.pop_front()
	
func is_menu_loaded():
	return current_menu != null
	
func is_previous_menu():
	return not menu_stack.is_empty()
		
func remove_children(node: Node):
	for child in node.get_children():
		if child.name == "Backround":
			continue
		node.remove_child(child)
		
class MenuState:
	extends RefCounted

	var type
	var backround: bool
	var args
	
	func _init(menu_type, show_backround, p_args = []):
		type = menu_type
		backround = show_backround
		args = p_args
