extends Object

# this class shall be extended by script chips

# callbacks (funcrefs)
var set_label_callback
var get_input_callback
var get_input_v_callback
var set_output_callback
var set_output_v_callback
var rebuild_callback

var label setget set_label

var properties = []

enum PropertyKind {TEXT, HEX_VALUE, TOGGLE, LIST, SIGNAL}

func create_property(name, kind, default, extras=null):
	var prop = {
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
	
	#print("creating property: ", prop)
	properties.append(prop)
	return prop

func set_label(label_):
	#print("setting label to ", label)
	set_label_callback.call_func(label_)
	label = label_

func get_input():
	return get_input_callback.call_func()
func get_input_v():
	return get_input_v_callback.call_func()
func set_output(output):
	set_output_callback.call_func(output)
func set_output_v(output):
	set_output_v_callback.call_func(output)

func rebuild():
	rebuild_callback.call_func()

func description():
	return label

func index_to_signal(index):
	return index-1

func on_property_changed(_p):
	pass

func set_property_value(name, value):
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
func get_property_value(name):
	for p in properties:
		if p.name == name:
			return p.value

func loop(_delta):
	pass
