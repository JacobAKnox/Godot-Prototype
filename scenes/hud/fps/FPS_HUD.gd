extends CanvasLayer

var prefix = ""

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$Label.set_text("%s FPS: %d" % [prefix, Engine.get_frames_per_second()])
	
func set_prefix(string):
	prefix = string
