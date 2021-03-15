extends "res://components/chips/ScriptChip/ScriptChipBase.gd"

var input_spec = {i0=8, i1=8, i2=8, i3=8}
var output_spec = {data=8}

func on_load():
	set_label("bus")

func on_set_input():
	var input_values = get_input().values()
	var value = input_values[0]
	for i in range(1, input_values.size()):
		for j in range(8):
			if value[j] == -1:
				value[j] = input_values[i][j]
	set_output_v(value)
