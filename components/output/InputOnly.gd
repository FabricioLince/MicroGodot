extends "res://components/Component.gd"

const is_io = true
var complex_use = Global.ComplexOutputUseKind.CHIP_OUTPUT

func set_connector_sizes(sizes):
	connectors.initialize_input_connectors(sizes)

func set_input(_signals, _index, _size):
	# child classes must implement this functions to 
	# receive input signals from input connectors
	pass


func get_info():
	var info = .get_info()
	info.complex_use = Global.ComplexOutputUseKind.keys()[complex_use]
	return info
func from_info(info):
	.from_info(info)
	if info.has("complex_use"):
		self.complex_use = Global.complex_output_use_from_string(info.complex_use)

func get_properties():
	var p = .get_properties()
	p.append({
		kind = "list",
		name = "complex_use",
		label = "Complex Use",
		items = Global.complex_output_use_captions,
	})
	return p

