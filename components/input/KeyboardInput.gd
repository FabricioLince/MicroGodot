extends "res://components/input/OutputOnly.gd"

onready var sprites = $Sprites
onready var pressed = $Sprites/Pressed
onready var unpressed = $Sprites/Unpressed

var scancode : int = KEY_A
var key_down := true
var scancode_name := "A" setget set_scancode_name

var state := 0 setget set_state

func _ready():
	set_connector_sizes([1])
	#connector = connectors.out_connectors[0]
	set_scancode_name(scancode_name)
	set_state()

func set_state(_s:=0):
	state = Signal.from(key_down == Keyboard.keys.get(scancode, false))
	send_output()
	sprites.modulate = Global.signal_to_color(state)
	if state:
		pressed.show()
		unpressed.hide()
	else:
		pressed.hide()
		unpressed.show()

func get_output() -> Array:
	return [state]

func component_name() -> String:
	return "KeyboardInput"

func get_info() -> Dictionary:
	var info := .get_info()
	info.erase("complex_use")
	info.scancode = self.scancode
	info.scancode_name = self.scancode_name
	info.key_down = self.key_down
	return info
func from_info(info:Dictionary):
	.from_info(info)
	self.scancode = info.scancode
	self.key_down = info.key_down
	self.scancode_name = info.scancode_name

func get_properties() -> Array:
	var p := [] #.get_properties()
	p.append({
		kind = "text",
		name = "scancode_name",
		label = "Scancode"
	})
	p.append({
		kind = "toggle",
		name = "key_down",
		label = "Key Down"
	})
	return p

func on_key_event(_pressed:bool):
	set_state()

func set_scancode_name(n:String):
	Keyboard.remove_listener(scancode, self, "on_key_event")
	n = n.to_upper()
	if n.length() == 1:
		var ascii : int = n.to_ascii()[0]
		if ascii >= KEY_A and ascii <= KEY_Z:
			_set_scancode(ascii, n.substr(0, 1))
		elif ascii >= KEY_0 and ascii <= KEY_9:
			_set_scancode(ascii, n.substr(0, 1))
	else:
		_set_scancode(0, " ")
		state = Signal.Kind.UNDEFINED
		sprites.modulate = Global.signal_to_color(state)
		send_output()

func _set_scancode(code:int, name:String):
	scancode_name = name
	scancode = code
	set_label("Key (%s)"%[scancode_name])
	Keyboard.add_listener(scancode, self, "on_key_event")
	$Sprites/Pressed/Label.text = name
	$Sprites/Unpressed/Label.text = name
	set_state()

func on_delete():
	Keyboard.remove_listener(scancode, self, "on_key_event")
	.on_delete()
