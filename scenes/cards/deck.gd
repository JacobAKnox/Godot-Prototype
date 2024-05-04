class_name Deck
extends Node

const NUM_CARDS := 4

signal card_removed(card: CardData)

@export var deck: Array[String] = ["card_basic", "card_basic", "card_basic", "card_basic"]

var cards: Array[Card] = []
var current_card := 0

var used = 0

var card_manager = CardManager

func setup(manager):
	card_manager = manager
	
func _ready():
	for id in deck:
		cards.append(Card.new(CardManager.get_card(id)))
	update_display()

func _input(event):
	if event.is_action_pressed("swap"):
		swap_attack()

func swap_attack():
	current_card += 1
	current_card %= 4
	update_display()

func get_attack(): 
	var attack = cards[current_card].use() 
	if attack != null:
		used += 1
		if used >= NUM_CARDS:
			reset_cards()
	swap_attack()
	return attack
	
func reset_cards():
	for card in cards:
		card.reset()
	used = 0
	
func update_display():
	var i := current_card
	for card in $CanvasLayer/MarginContainer/HBoxContainer.get_children():
		update_card_display(cards[i % NUM_CARDS], card)
		i+=1
	
func update_card_display(card: Card, display: CardDisplay):
	display.setup(card.name, card.used)

func get_all_cards():
	return deck
	
func replace_card(index: int, new_card: CardData) -> void:
	var old_card: CardData = CardManager.get_card(deck[index])
	card_removed.emit(old_card)
	cards[index] = Card.new(new_card)
	deck[index] = new_card.id
	reset_cards()
	update_display()
