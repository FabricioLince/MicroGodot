extends "res://components/chips/ScriptChip/ScriptChipBase.gd"

const sizes = [4, 8, 12, 16]
var size_prop := create_property("Size", PropertyKind.LIST, 0, {items=sizes})

#-- input/output especification
var input_spec := {inc =  1, reset = 1}
var output_spec := {count = 4, overflow = 1}

var inc := false
var count := 0
var overflow := 0

func max_count() -> int:
	return Signal.Utils.int_pow(2, output_spec.count)

#-- called when this gate is instantiated
func on_load():
	set_label("Counter")

#-- called when gate input changes
func on_set_input():
	var input := get_input()
	if input.inc == 1:
		if not inc:
			inc = true
			count += 1
			overflow = 0
			if count >= max_count():
				count = 0
				overflow = 1
	elif input.inc == 0:
		inc = false
	if input.reset == 1:
		count = 0
		overflow = 0
	set_output({count = count, overflow = overflow})

func on_property_changed(p):
	if p.name == "Size":
		output_spec.count = sizes[p.index]
		rebuild()

