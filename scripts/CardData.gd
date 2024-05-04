class_name CardData
extends Resource

@export var attack: PackedScene
@export var att_override: PackedScene
@export var name: String
@export var id: String

func _init(p_attack = null, a_override = null, p_name = "", p_id = ""):
	attack = p_attack
	att_override = a_override
	name = p_name
	id = p_id
