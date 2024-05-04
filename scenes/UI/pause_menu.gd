extends Control

func _enter_tree():
	call_deferred("setup")
	
func setup():
	$VBoxContainer/ResumeButton.grab_focus()

func _on_resume_button_pressed():
	MenuManager.load_menu(MenuLevel.NONE)

func _on_options_button_pressed():
	MenuManager.load_menu(MenuLevel.OPTIONS, false)

func _on_quit_title_button_pressed():
	Config.get_game().quit_title()

func _on_quit_game_button_pressed():
	Config.get_game().quit()
