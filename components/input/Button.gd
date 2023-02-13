extends "res://components/input/OutputOnly.gd"

onready var sprites = $Sprites
onready var pressed = $Sprites/Pressed
onready var unpressed = $Sprites/Unpressed

var state := 0 setget set_state

func set_state(s:int):
	state = Signal.from(s)
	send_output()
	if state:
		sprites.modulate = Global.signal_to_color(1)
		pressed.show()
		unpressed.hide()
	else:
		sprites.modulate = Global.signal_to_color(0)
		pressed.hide()
		unpressed.show()

var connector = null

func _ready():
	set_connector_sizes([1])
	connector = connectors.out_connectors[0]
	self.state = 0

func get_output() -> Array:
	return [state]

func flip_state():
	self.state = not state

func on_simple_click(info:Dictionary):
	if info.event.button_index == BUTTON_LEFT:
		flip_state()

func component_name() -> String:
	return "Button"

func get_info() -> Dictionary:
	var info := .get_info()
	info.state = self.state
	return info
func from_info(info:Dictionary):
	.from_info(info)
	self.state = info.state

func get_properties() -> Array:
	var p := .get_properties()
	p.append({
		kind = "toggle",
		name = "state",
		label = "State"
	})
	return p

