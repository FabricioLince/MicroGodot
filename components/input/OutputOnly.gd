extends "res://components/Component.gd"

const is_io = true
var complex_use = Global.ComplexInputUseKind.CHIP_INPUT

func set_connector_sizes(sizes):
	connectors.initialize_output_connectors(sizes)

# function to let connectors know that that output has changed
func send_output():
	for c in connectors.out_connectors:
		c.set_signals(get_output())

func get_output():
	# child classes must implemented this function to return an Array
	# with all the output signals back to back
	pass


func get_info():
	var info = .get_info()
	info.complex_use = Global.ComplexInputUseKind.keys()[complex_use]
	return info
func from_info(info):
	.from_info(info)
	if info.has("complex_use"):
		self.complex_use = Global.complex_input_use_from_string(info.complex_use)

func get_properties():
	var p = .get_properties()
	p.append({
		kind = "list",
		name = "complex_use",
		label = "Complex Use",
		items = Global.complex_input_use_captions,
	})
	return p

