extends Control

var deck: Deck
var new_card: CardData

func arg_apply(args) -> void:
	deck = args[0]
	new_card = args[1]
	var cards = deck.get_all_cards()
	for i in len(cards):
		$MarginContainer/MarginContainer/HBoxContainer/GridContainer.get_child(i).setup(CardManager.get_card(cards[i]).name, false)
	
	$MarginContainer/MarginContainer/HBoxContainer/CardDisplay.setup(new_card.name, false)

func _on_new_card_button_pressed() -> void:
	MenuManager.load_last_menu()

func _on_card_0_button_pressed() -> void:
	replace_card(0)

func _on_card_1_button_pressed() -> void:
	replace_card(1)

func _on_card_2_button_pressed() -> void:
	replace_card(2)

func _on_card_3_button_pressed() -> void:
	replace_card(3)

func replace_card(index: int) -> void:
	deck.replace_card(index, new_card)
	MenuManager.load_last_menu()
