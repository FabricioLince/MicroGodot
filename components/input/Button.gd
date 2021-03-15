extends "res://components/input/OutputOnly.gd"

var state = 0 setget set_state, get_state
func set_state(s):
	state = Signal.from(s)
	send_output()
	if state:
		$Sprites.modulate = Global.signal_to_color(1)
		$Sprites/Pressed.show()
		$Sprites/Unpressed.hide()
	else:
		$Sprites.modulate = Global.signal_to_color(0)
		$Sprites/Pressed.hide()
		$Sprites/Unpressed.show()
func get_state():
	return state

var connector = null

func _ready():
	set_connector_sizes([1])
	connector = connectors.out_connectors[0]
	self.state = false

func get_output():
	return [state]

func flip_state():
	self.state = not state

func on_simple_click(info):
	if info.event.button_index == BUTTON_LEFT:
		flip_state()

func component_name():
	return "Button"

func get_info():
	var info = .get_info()
	info.state = self.state
	return info
func from_info(info):
	.from_info(info)
	self.state = info.state

func get_properties():
	var p = .get_properties()
	p.append({
		kind = "toggle",
		name = "state",
		label = "State"
	})
	return p

