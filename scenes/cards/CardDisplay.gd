class_name CardDisplay
extends Panel

const USED_THEME := preload("res://scenes/cards/CardDisplayUsed.tres")
const UNUSED_THEME := preload("res://scenes/cards/CardDisplayUnused.tres")

func setup(card_name, used):
	$VBoxContainer/Name.text = card_name
	update_use(used)
	
func update_use(used):
	if used:
		remove_theme_stylebox_override("panel")
		add_theme_stylebox_override("panel", USED_THEME)
	else:
		remove_theme_stylebox_override("panel")
		add_theme_stylebox_override("panel", UNUSED_THEME)
