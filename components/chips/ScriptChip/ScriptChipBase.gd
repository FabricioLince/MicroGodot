extends Reference

# this class shall be extended by script chips

# callbacks (funcrefs)
var set_label_callback
var get_input_callback
var get_input_v_callback
var set_output_callback
var set_output_v_callback
var rebuild_callback
var node : Node

var label : String setget set_label

var properties := []

enum PropertyKind {TEXT, HEX_VALUE, TOGGLE, LIST, SIGNAL, BUTTON}

func create_property(name:String, kind:int, default, extras=null) -> Dictionary:
	var prop := {
		label = name,
		name = name,
		value = default,
	}
	
	match(kind):
		PropertyKind.TEXT:
			prop.kind = "text"
		PropertyKind.HEX_VALUE:
			prop.kind = "hex_value"
		PropertyKind.TOGGLE:
			prop.kind = "toggle"
		PropertyKind.LIST:
			prop.kind = "list"
			prop.items = extras.items
			prop.index = default
		PropertyKind.SIGNAL:
			prop.kind = "list"
			prop.hint = "signal"
			prop.items = Signal.Kind.keys()
			prop.signal = default
			prop.index = default+1
			prop.value = default+1
		PropertyKind.BUTTON:
			prop.kind = "button"
			prop.callback = funcref(self, default)
	
	#print("creating property: ", prop)
	properties.append(prop)
	return prop

func set_label(label_:String):
	#print("setting label to ", label)
	set_label_callback.call_func(label_)
	label = label_

func get_input() -> Dictionary:
	return get_input_callback.call_func()
func get_input_v() -> Array:
	return get_input_v_callback.call_func()
func set_output(output:Dictionary):
	set_output_callback.call_func(output)
func set_output_v(output:Array):
	set_output_v_callback.call_func(output)

func rebuild():
	rebuild_callback.call_func()

func description() -> String:
	return label

func index_to_signal(index:int) -> int:
	return index-1

func on_property_changed(_p):
	pass

func set_property_value(name:String, value):
	for p in properties:
		if p.name == name:
			if p.kind == "list":
				value = int(value)
				p.index = value
			if p.get("hint") == "signal":
				p.signal = index_to_signal(value)
				
			p.value = value
			on_property_changed(p)
			return true
func get_property_value(name:String):
	for p in properties:
		if p.name == name:
			return p.value

