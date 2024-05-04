extends ResourcePreloader

@export var default_card: CardData

func get_card(id: String) -> CardData:
	if id in get_resource_list():
		return get_resource(id)
	else:
		return default_card
