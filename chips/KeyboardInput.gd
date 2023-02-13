extends "res://components/chips/ScriptChip/ScriptChipBase.gd"

var scancode_prop := create_property("Key", PropertyKind.TEXT, "A")
var toggle_prop := create_property("Toggle", PropertyKind.TOGGLE, false)
var invert_prop := create_property("Invert", PropertyKind.TOGGLE, false)

const input_spec := {}
const output_spec := {key=1}

var scancode : int = KEY_A

var state := 0

func on_load():
	#connector = connectors.out_connectors[0]
	set_scancode_name(scancode_prop.value)
	update()

func on_set_input():
	pass

func update():
	state = Signal.from(invert_prop.value != Keyboard.keys.get(scancode, false))
	set_output_v([state])
#	sprites.modulate = Global.signal_to_color(state)
#	if state:
#		pressed.show()
#		unpressed.hide()
#	else:
#		pressed.hide()
#		unpressed.show()

var down := false
func on_key_event(pressed:bool):
	if toggle_prop.value:
		if pressed:
			if pressed != down:
				state = Signal.from(!state)
				set_output_v([state])
		down = pressed
	else:
		update()

func on_property_changed(prop:Dictionary):
	if prop.name == "Key":
		set_scancode_name(prop.value)

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
		#sprites.modulate = Global.signal_to_color(state)
		update()

func _set_scancode(code:int, name:String):
	scancode_prop.value = name
	scancode = code
	set_label("Key (%s)"%[scancode_prop.value])
	Keyboard.add_listener(scancode, self, "on_key_event")
#	$Sprites/Pressed/Label.text = name
#	$Sprites/Unpressed/Label.text = name
	update()

func on_delete():
	Keyboard.remove_listener(scancode, self, "on_key_event")
