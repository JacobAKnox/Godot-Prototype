extends Polygon2D

@export var card: CardData
var deck: Deck

func _physics_process(_delta: float) -> void:
	if deck != null:
		deck.card_removed.disconnect(get_removed_card)
		deck = null

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and $PlayerDectector.player_inside:
		deck= $PlayerDectector.player.get_deck()
		deck.card_removed.connect(get_removed_card)
		MenuManager.load_menu(MenuLevel.PICKUP, false, [deck, card])
		get_tree().paused = true

func get_removed_card(new_card: CardData):
	deck.card_removed.disconnect(get_removed_card)
	card = new_card
	deck = null

func _on_player_dectector_player_near() -> void:
	$ActionIcon.show()

func _on_player_dectector_player_far() -> void:
	$ActionIcon.hide()
