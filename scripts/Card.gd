class_name Card
extends RefCounted

var attack: PackedScene
var a_override: PackedScene
var name: String
var id: String
var used := false

func _init(data: CardData):
	attack = data.attack
	a_override = data.att_override
	name = data.name
	id = data.id
	
func use():
	if used:
		return null
	used = true
	return [attack, a_override]
	
func reset():
	used = false
