extends "res://components/Component.gd"

const is_io = true
var complex_use : int = Global.ComplexInputUseKind.CHIP_INPUT

func set_connector_sizes(sizes:Array):
	connectors.initialize_output_connectors(sizes)

# function to let connectors know that that output has changed
func send_output():
	for c in connectors.out_connectors:
		c.set_signals(get_output())

func get_output() -> Array:
	# child classes must implemented this function to return an Array
	# with all the output signals back to back
	push_error("get_output() of OutputOnly needs to be overriden")
	return []

func force_output():
#	var decoy := []
#	for s in get_output():
#		if s == 0:
#			decoy.append(-1)
#		else:
#			decoy.append(0)
#	for c in connectors.out_connectors:
#		c.set_signals(decoy)
#	yield(get_tree(), "idle_frame")
	send_output()

func get_info() -> Dictionary:
	var info := .get_info()
	info.complex_use = Global.ComplexInputUseKind.keys()[complex_use]
	return info
func from_info(info:Dictionary):
	.from_info(info)
	if info.has("complex_use"):
		self.complex_use = Global.complex_input_use_from_string(info.complex_use)

func get_properties() -> Array:
	var p := .get_properties()
	p.append({
		kind = "list",
		name = "complex_use",
		label = "Complex Use",
		items = Global.complex_input_use_captions,
	})
	return p

