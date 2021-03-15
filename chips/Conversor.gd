extends "res://components/chips/ScriptChip/ScriptChipBase.gd"

#-- properties
var input_prop = create_property("from", PropertyKind.SIGNAL, Signal.Kind.UNDEFINED)
var output_prop = create_property("to", PropertyKind.SIGNAL, Signal.Kind.LOW)

#-- input/output especification
var input_spec = {"in" : 1}
var output_spec = {out = 1}

func signal_name(sig):
	match(sig):
		Signal.Kind.UNDEFINED:
			return "u"
		Signal.Kind.LOW:
			return "0"
		Signal.Kind.HIGH:
			return "1"

func rename():
	set_label(signal_name(input_prop.signal)+"->"+signal_name(output_prop.signal))

#-- called when this gate is instantiated
func on_load():
	rename()

#-- called when gate input changes
func on_set_input():
	var input = get_input()
	if input["in"] == input_prop.signal:
		set_output({out = output_prop.signal})
	else:
		set_output({out = input["in"]})

func on_property_changed(_prop):
	rename()
	on_set_input()

func description():
	return "Conversor"
