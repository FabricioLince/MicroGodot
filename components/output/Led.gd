extends "res://components/output/InputOnly.gd"

var state = false setget set_state, get_state
func set_state(s):
	state = Signal.from(s)
	$Sprite.modulate = Global.signal_to_color(state)
func get_state():
	return state

var connector = null

func _ready():
	set_connector_sizes([1])
	connector = connectors.in_connectors[0]
	self.state = null

func set_input(signals, index, _size):
	if signals.size() == 0:
		self.state = -1
	else:
		self.state = signals[index]


func component_name():
	return "Led"
