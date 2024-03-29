extends Reference

signal on_output_changed(new_output)
signal on_label_changed(new_label)
signal on_rebuild()

var inner_id := -1

var file_path : String setget set_file_path
func set_file_path(path:String):
	load_script(path)

var chip
var has_loop := false
var node : Node

var input := []
var output := []

var input_spec
var output_spec
var input_sizes := []
var input_names := []
var output_sizes := []
var output_names := []
var input_dic := {}

var force_next_amount := 1

func load_script(path:String) -> bool:
	file_path = path
	if Global.builtin_chips.has(path):
		#print("has built in ", path)
		chip = Global.builtin_chips[path].new()
	else:
		var full_path := Global.script_chip_full_path2(path)
		if File.new().file_exists(full_path):
			var chip_script := ResourceLoader.load(full_path)
			chip = chip_script.new()
	if is_instance_valid(chip):
		return set_chip_script(chip)
	else:
		push_error("'%s' could not be found"%Global.script_chip_full_path2(path))
		set_label("ERROR")
		return false

func set_chip_script(chip_):
	chip = chip_
	chip.node = node
	chip.set_label_callback = funcref(self, "set_label")
	chip.get_input_callback = funcref(self, "get_input_callback")
	chip.get_input_v_callback = funcref(self, "get_input_v_callback")
	chip.set_output_callback = funcref(self, "set_output_callback")
	chip.set_output_v_callback = funcref(self, "set_output_v_callback")
	chip.rebuild_callback = funcref(self, "rebuild_callback")
	has_loop = chip.has_method("loop")
	return rebuild_callback()
	

func rebuild_callback():
	initialize_io()
	chip.on_load()
	update_input_dic()
	chip.on_set_input()
	emit_signal("on_rebuild")
	return true

func initialize_io():
	input_spec = chip.get("input_spec")
	if input_spec:
		input_sizes = []
		input_names = []
		for i in input_spec:
			input_sizes.append(input_spec[i])
			input_names.append(str(i))
	else:
		input_spec = []
	input = []
	for s in input_sizes:
		for _i in range(s):
			input.append(-9999)
		#initial_counter += s
	
	output_spec = {}
	var chip_spec = chip.get("output_spec")
	if chip_spec:
		output_sizes = []
		output_names = []
		for o in chip_spec:
			output_sizes.append(chip_spec[o])
			output_names.append(str(o))
	var index := 0
	for o_spec in chip_spec:
		output_spec[o_spec] = {index = index, size = chip_spec[o_spec]}
		index += output_spec[o_spec].size
	#print(output_spec)
	output = []
	for s in output_sizes:
		for _i in range(s):
			output.append(-1)

func force_next():
	force_next_amount = 2

func set_input(signals:Array, index:int):
	#var changed := force_next_amount > 0
	for i in range(signals.size()):
#		if input[i+index] != signals[i]:
#			changed = true
		input[i+index] = signals[i]
	#print("%s input is now %s"%[to_string(), str(input)])
#	if not changed:
#		return
#	force_next_amount -= 1
	update_input_dic()
	chip.on_set_input()

func update_input_dic():
	var count := 0
	for i_name in input_spec:
		var ar = input.slice(count, count+input_spec[i_name]-1)
		count += input_spec[i_name]
		if ar.size() == 1:
			input_dic[i_name] = ar[0]
		else:
			input_dic[i_name] = ar
		#print(i_name, " = ", ar)

func get_output() -> Array:
	return output

func set_output_callback(output_dic:Dictionary):
	#print("setting output to ", output_dic)
	var changed := force_next_amount > 0
	for o_name in output_dic:
		var o_value = output_dic[o_name]
		var index = output_spec[o_name].index
		match typeof(o_value):
			TYPE_INT:
				var list = Signal.List.from_number(o_value, output_spec[o_name].size)
				output_dic[o_name] = list
				#print(o_name, " value is ", list)
			TYPE_BOOL:
				#print(o_name, " value is ", Signal.from(o_value))
				output_dic[o_name] = [Signal.from(o_value)]
			_:
				push_error("no match for %s (%d)"%[str(o_value), typeof(o_value)])
		for i in range(output_spec[o_name].size):
			if output[i+index] != output_dic[o_name][i]:
				changed = true
				output[i+index] = output_dic[o_name][i]
	#print("output is now: ", output)
	if changed:
		emit_signal("on_output_changed", output)

func set_output_v_callback(signals:Array, start_index:=0):
	#var changed := force_next_amount > 0
	var i := 0
	while start_index+i < output.size():
		if i >= signals.size(): break
		if output[start_index+i] != signals[i]:
			#changed = true
			output[start_index+i] = signals[i]
		i += 1
	#if true or changed:
	emit_signal("on_output_changed", output)
		#print("%s output is now %s"%[to_string(), str(output)])


func get_input_callback() -> Dictionary:
	return input_dic
func get_input_v_callback() -> Array:
	return input
func set_label(l:String):
	emit_signal("on_label_changed", l)

func loop(delta:float):
	if has_loop: 
		chip.loop(delta)

func description() -> String:
	return chip.description()


func get_properties() -> Array:
	return chip.properties
func get(prop_name : String):
	return chip.get_property_value(prop_name)
func set(prop_name : String, prop_value):
	return chip.set_property_value(prop_name, prop_value)

func get_properties_info():
	var properties := get_properties()
	if properties.size() > 0:
		var info := []
		for prop in get_properties():
			info.append({
				name = prop.name,
				value = prop.value
			})
		return info
func set_properties_from_info(info:Array):
	for p in info:
		set(p.name, p.value)

func _to_string():
	return description()+_properties_summary()
func _properties_summary():
	var s := "{"
	for p in get_properties():
		s+=p.name+"="+str(p.value)+";"
	return s+"}"
func print_signal_connections():
	for s in get_signal_list():
		#print(s)
		for c in get_signal_connection_list(s.name):
			print(c)

func on_delete():
	if is_instance_valid(chip) and chip.has_method("on_delete"):
		chip.on_delete()
