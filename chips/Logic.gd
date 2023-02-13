extends "res://components/chips/ScriptChip/ScriptChipBase.gd"

enum Kind {And, Or, Xor}

#-- properties
var kind_prop = create_property("Kind", PropertyKind.LIST, 0, {items=Kind.keys()})

#-- input/output especification
var input_spec := {i0=1, i1=1}
var output_spec := {o=1}

#-- called when this gate is instantiated
func on_load():
	rename()

#-- called when gate input changes
func on_set_input():
	set_output_v([calc_by_kind(kind_prop.index, get_input_v())])


static func calc_by_kind(kind_:int, input_:Array) -> int:
	for i in input_:
		if i == -1:
			return -1
	match kind_:
		Kind.And:
			return input_.min()
		Kind.Or:
			return input_.max()
		Kind.Xor:
			if input_[0] != input_[1]:
				return 1
			else:
				return 0
	print("something wrong with ", kind_, " -> ", input_)
	return -1

func on_property_changed(_prop):
	rename()
	on_set_input()

func rename():
	set_label(Kind.keys()[kind_prop.index])
func description() -> String:
	return "Logic Chip"
