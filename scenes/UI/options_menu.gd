extends Control

func _ready():
	setup()
	
func _enter_tree():
	call_deferred("setup")

func _input(event):
	if event.is_action_pressed("ui_right"):
		focus_next_tab()
	if event.is_action_pressed("ui_left"):
		focus_prev_tab()
		
func focus_next_tab():
	var tabs = $MarginContainer/TabContainer
	if tabs.current_tab >= tabs.get_tab_count() - 1:
		tabs.current_tab = 0
	else:
		tabs.current_tab += 1

func focus_prev_tab():
	var tabs = $MarginContainer/TabContainer
	if tabs.current_tab <= 0:
		tabs.current_tab = tabs.get_tab_count() - 1
	else:
		tabs.current_tab -= 1
		
func setup():
	$MarginContainer/TabContainer.current_tab = 0

func _on_exit_button_pressed():
	MenuManager.load_last_menu()

func exit():
	MenuManager.load_last_menu()
	
