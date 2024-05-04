extends Control

func _enter_tree():
	call_deferred("setup")
	
func setup():
	$MainMenu/VBoxContainer/StartButton.grab_focus()

func _on_start_button_pressed():
	Config.get_game().start_game()

func _on_exit_button_pressed():
	get_tree().quit()

func _on_options_button_pressed():
	MenuManager.load_menu(MenuLevel.OPTIONS)
