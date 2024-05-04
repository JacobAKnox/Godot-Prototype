extends Control

@export var card_display: PackedScene

func _input(event):
	if event.is_action_pressed("inventory"):
		MenuManager.load_last_menu()

func arg_apply(deck):
	var grid = $MarginContainer/MarginContainer/ScrollContainer/GridContainer
	for child in grid.get_children():
		grid.remove_child(child)
	for item in deck:
		var card: CardData = CardManager.get_card(item)
		var display = card_display.instantiate()
		display.setup(card.name, false)
		grid.add_child(display)
