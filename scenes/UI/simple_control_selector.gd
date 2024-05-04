extends HBoxContainer

enum WaitingFor {NONE, KEY, CONTROLLER}

var cremap: ControlsRemap
var waiting: WaitingFor = WaitingFor.NONE
@export var action: String = "jump"
@export var nice_name: String = "input"

func setup(ctrl_remap):
	cremap = ctrl_remap
	
func _ready():
	if ResourceLoader.exists(Config.inputs_file):
		cremap = load(Config.inputs_file)
		cremap.apply_remap()
		get_tree().call_group(&"action_icons", &"refresh")
	else:
		cremap = ControlsRemap.new()
	$InputName.text = nice_name
	$KeyboardButton/KeyboardActionIcon.action_name = action
	$ControllerButton/ControllerActionIcon.action_name = action

func _input(event):
	if waiting == WaitingFor.NONE or event.is_action("ui_cancel"):
		return
	
	if event is InputEventKey and waiting == WaitingFor.KEY:
		cremap.set_action_key(action, event)
	elif event is InputEventJoypadButton and waiting == WaitingFor.CONTROLLER:
		cremap.set_action_button(action, event)
	else:
		return
	
	waiting = WaitingFor.NONE
	refresh_view()
	save_remap()
	
func save_remap():
	cremap.create_remap()
	ResourceSaver.save(cremap, Config.inputs_file)
	
func refresh_view():
	get_tree().call_group(&"action_icons", &"refresh")	
	
func _on_keyboard_button_pressed():
	waiting = WaitingFor.KEY

func _on_controller_button_pressed():
	waiting = WaitingFor.CONTROLLER

func _on_reset_button_pressed():
	cremap.restore_action_default(action)
	refresh_view()
	save_remap()
