extends "res://components/chips/ScriptChip/ScriptChipBase.gd"

var sizes = [1, 4, 8, 12, 16]
var size_prop = create_property("Size", PropertyKind.LIST, 0, {items=sizes})

#-- input/output especification
var input_spec = {"in" : 1}
var output_spec = {out = 1}

#-- called when this gate is instantiated
func on_load():
	set_label("Inverter")

#-- called when gate input changes
func on_set_input():
	var input = get_input_v()
	var output = []
	for s in input:
		output.append(Signal.invert(s))
	set_output_v(output)

func on_property_changed(_p):
	input_spec = {"in" : sizes[size_prop.index]}
	output_spec = {"out" : sizes[size_prop.index]}
	rebuild()
