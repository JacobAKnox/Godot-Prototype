extends Node2D

var collected := false

signal on_collect

func try_collect() -> bool:
	if $PlayerDectector.player_inside and not collected:
		on_collect.emit()
		return true
	return false
