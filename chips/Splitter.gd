extends "res://components/chips/ScriptChip/ScriptChipBase.gd"

const sizes = [4, 8, 12, 16]
var io_sizes = [1, 4]
var size_prop = create_property("Size", PropertyKind.LIST, 0, {items=sizes})
var input_prop = create_property("Input Bits", PropertyKind.LIST, 1, {items=io_sizes})
var output_prop = create_property("Output Bits", PropertyKind.LIST, 0, {items=io_sizes})

#-- input/output especification
var input_spec = {"in" : 4}
var output_spec = {o0=1, o1=1, o2=1, o3=1}

#-- called when this gate is instantiated
func on_load():
	rename()

#-- called when gate input changes
func on_set_input():
	set_output_v(get_input_v())

func on_property_changed(p):
	if p.name == "Size":
		io_sizes = [1]
		for i in range(p.index+1):
			io_sizes.append(sizes[i])
		input_prop.items = io_sizes
		output_prop.items = io_sizes
		if input_prop.index > p.index+1:
			input_prop.index = p.index+1
		if output_prop.index > p.index+1:
			output_prop.index = p.index+1
	setup_io()
	rename()
	rebuild()

func setup_io():
	var bits_count = sizes[size_prop.index]
	var i_count = io_sizes[input_prop.index]
	var o_count = io_sizes[output_prop.index]

	input_spec = {}
	for i in range((bits_count/i_count)):
		input_spec["i"+str(i)] = i_count
	
	output_spec = {}
	for i in range((bits_count/o_count)):
		output_spec["o"+str(i)] = o_count

func rename():
	if input_prop.index < output_prop.index:
		set_label("Merger")
	else:
		set_label("Splitter")
