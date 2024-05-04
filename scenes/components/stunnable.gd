class_name Stunnable
extends Timer

signal stun_over

var stunned := false

func stun():
	start()
	stunned = true
	
func _on_timeout() -> void:
	stunned = false
	stun_over.emit()
