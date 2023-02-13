extends Reference

const ScriptChip = preload("res://components/chips/Simulated/ScriptChip.gd")

signal on_output_changed(new_output)
signal on_label_changed(new_label)

var inner_id := -1

var ordered_input := []
var ordered_output := []
var input_components := {}
var output_components := {}
var chips := {}
var connections := []
var input := []
var output := []
var constants := []

var input_sizes := []
var input_names := []

var tree : SceneTree
var has_loop := false
var node : Node

func _init(tree_:SceneTree):
	self.tree = tree_

func load_from_path(path:String):
	var full_path := Global.complex_chip_full_path(path)
	var all = FileCache.get_json(full_path)
	if all:
		var regex := RegEx.new()
		regex.compile("(?<name>[\\s\\w\\(\\)\\[\\]]+)\\.chip")
		var mat := regex.search(path)
		if mat:
			emit_signal("on_label_changed", mat.get_string("name"))
		else:
			var pieces := path.split("/")
			var name = pieces[pieces.size()-1]
			emit_signal("on_label_changed", name)
		return load_from_json(all)
	else:
		push_error("'%s' could not be found"%full_path)
		FileCache.add_dependency_error(path)

func load_from_json(all:Dictionary):
	load_io(all.io)
	
	load_inner_chips(all.chips)
	
	load_extras(all.get("extras", []))
	
	load_inner_connections(all.connections)
	
	var total_output_size := 0
	for o in ordered_output:
		total_output_size += o.size
	put_on_output(Signal.List.repeat(-1, total_output_size), 0)
	emit_signal("on_output_changed", output)
	for c in constants: # initialize the constants
		c.emit_value()
	return true

var InputObjects := {Button=SimButton, HexInput=SimHexInput}
func load_io(io_info_list):
	for io in io_info_list:
		SerializerHelper.renormalize(io)
		match io.type:
			"Button", "HexInput":
				var comp = InputObjects[io.type].new(io)
				if comp.constant:
					constants.append(comp)
				else:
					input_components[io.id] = comp
					ordered_input.append(comp)
			"Led", "HexDisplay":
				var ignore = io.has("complex_use") and Global.complex_output_use_from_string(io.complex_use) == Global.ComplexOutputUseKind.IGNORE
				var out := {
					id = io.id,
					size = io.get("bits", 1), # LED doesn't have 'bits' set in the info dictionary
					label = io.label,
					position = io.position,
					ignore = ignore,
				}
				if not ignore:
					output_components[io.id] = out
					ordered_output.append(out)
			_:
				print("ERROR: unrecognized io: %s"%str(io.type))
				push_error("ERROR: unrecognized io: %s"%str(io.type))
				return
	# -- sort by Y position and assign index based on the sorting position
	ordered_input.sort_custom(self, "_sort_io")
	ordered_output.sort_custom(self, "_sort_io")
	for index in range(ordered_input.size()):
		ordered_input[index].index = index
	for index in range(ordered_output.size()):
		ordered_output[index].index = index
	# -- store ordered sizes and names
	for i in ordered_input:
		input_sizes.append(i.size)
		input_names.append(i.label)
	
	for o in output_components:
		for _i in range(output_components[o].size):
			output.append(-1)

func _sort_io(a, b):
	return a.position.y > b.position.y

func load_inner_chips(chip_info_list:Array):
	var ComplexChip = get_script()
	for chip_info in chip_info_list:
		chip_info.id = int(chip_info.id)
		var chip 
		match (chip_info.type):
			"ScriptChip":
				chip = ScriptChip.new()
				chip.node = node
				chip.load_script(chip_info.path)
				if chip_info.has("properties"):
					chip.set_properties_from_info(chip_info.properties)
			"ComplexChip":
				chip = ComplexChip.new(tree)
				chip.node = node
				chip.load_from_path(chip_info.path)
		chips[chip_info.id] = chip
		chip.inner_id = chip_info.id
		has_loop = has_loop or chip.has_loop
	#print("Chips: ", chips)

func load_extras(extra_list:Array):
	for info in extra_list:
		SerializerHelper.renormalize(info)
		print(info)
		match info.type:
			"Bus":
				var bus_sim := preload("res://components/Bus.gd").Simulated.new()
				var chip := ScriptChip.new()
				chip.node = node
				chip.set_chip_script(bus_sim)
				chips[info.id] = chip
				chip.inner_id = info.id

func load_inner_connections(con_info_list:Array):
	for con_info in con_info_list:
		SerializerHelper.renormalize(con_info)
		var con := SimConnection.new(tree)
		connections.append(con)
		
		if chips.has(con_info.from): # -- From Chip
			var chip = chips[con_info.from]
			#print("From Chip %s"%chip.description())
			chip.connect("on_output_changed", con, "slice_and_send")
		elif input_components.has(con_info.from): # -- From Input
			var i = input_components[con_info.from]
			#print("From Input %s"%i.label)
			i.connect("value_changed", con, "input_changed")
		else:
			var from_constant = false
			for c in constants:
				if c.id == con_info.from:
					from_constant = true
					c.connect("value_changed", con, "input_changed")
			if not from_constant:
				# connection comes from nowhere?
				connections.erase(con)
				continue
		
		if chips.has(con_info.to): # -- To Chip
			var chip = chips[con_info.to]
			#print("To chip %s"%chips[con_info.to].description())
			con.to_index = con_info.to_index
			con.put_on_callback = funcref(chip, "set_input")
			con.slice_start = con_info.from_index
			var chip_connector_size
			var to_index = con_info.to_index # cumulativo
			for size in chip.input_sizes:
				if to_index == 0:
					chip_connector_size = size
					break
				to_index -= size
			if chip_connector_size:
				con.slice_end = con.slice_start+chip_connector_size-1
			else: # -- connected chip couldn't be loaded
				con.slice_end = con.slice_start # -- just so it doesn't break everything
			
		elif output_components.has(con_info.to): # -- To Output
			var o = output_components[con_info.to]
			var index := 0
			for o_comp in ordered_output:
				if o_comp.id == con_info.to:
					con.to_index = index
					break
				else:
					index += o_comp.size
			con.put_on_callback = funcref(self, "put_on_output")
			con.slice_start = con_info.from_index
			con.slice_end = con.slice_start + o.size - 1
			
			if o.ignore:
				print("ignoring ", o)
		else:
			# connection goes nowhere?
			# or the output is ignored
			connections.erase(con)
			continue

func loop(delta:float):
	for c in chips:
		chips[c].loop(delta)

func set_input(signals:Array, index:int):
#	print("ComplexChip::set_input(%s, %d)"%[str(signals), index])
	for i in ordered_input:
		if index == 0:
			i.value = signals
			break
		index -= i.size
	input = []
	for comp in ordered_input:
		input.append_array(comp.value)
#	print("inner id = %d: %s -> %s"%[inner_id, str(input), str(output)])

func put_on_output(signals, start_index):
	#print("putting result on output: ", signals, start_index)
	var i = 0
	while start_index+i < output.size() and i < signals.size():
		output[start_index+i] = signals[i]
		i += 1
	emit_signal("on_output_changed", output)

func force_next():
#	for c in connections:
#		c.force_pass = true
	for c in chips.values():
		if c.has_method("force_next"):
			c.force_next()
#	yield(tree, "idle_frame")
#	for c in connections:
#		c.force_pass = false

class SimInput:
	extends Reference
	signal value_changed(new_value)
	var id : int
	var index : int
	var size : int
	var label : String
	var position : Vector2
	var constant := false
	var value : Array setget set_value
	func _init(info):
		id = info.id
		label = info.label
		position = info.position
		if info.has("complex_use"):
			constant = Global.complex_input_use_from_string(info.complex_use) == Global.ComplexInputUseKind.CONSTANT
	func set_value(v:Array):
		if value == v:
#			print(label,"	Didnt pass ", v, " ", value)
			return
#		print("SimInput %s changed to %s"%[label, str(v)])
		value = v
		emit_signal("value_changed", value)
	func _to_string():
		return "Input:%s(%s)"%[label, value]
	func emit_value():
		emit_signal("value_changed", value)

class SimButton:
	extends SimInput
	func _init(info).(info):
		size = 1
		if constant:
			value = [Signal.from(info.state)]
		#print("%s value is %s"%[label, Signal.name(value[0])])

class SimHexInput:
	extends SimInput
	func _init(info).(info):
		size = info.get("bits", 4)
		if info.has("show_value_as"):
			var sva = Global.show_value_kind_from_string(info.show_value_as)
			if constant:
				if sva == Global.ShowValueKind.PURE_VALUE:
					value = Signal.List.from_number(info.value, size)
				else:
					value = Signal.List.from_twos_complement(info.value, size)
		#print("%s value is %s"%[label, value])

class SimConnection:
	extends Reference
	var to_index : int
	var put_on_callback : FuncRef
	var slice_start : int
	var slice_end : int
	var tree : SceneTree
	var prev_value : Array # to not send signals unnecessarily
	var frame := 0
	
	func _init(tree_:SceneTree):
		self.tree = tree_
	func input_changed(input:Array):
		if input == prev_value: 
			return
		
		#print(input, " to index: ", to_index)
#		if tree.get_frame() == frame:
#			yield(tree, "idle_frame")
		prev_value = input
		frame = tree.get_frame()
		put_on_callback.call_func(input, to_index)
	func slice_and_send(input:Array):
		#print("slicing %s %s-%s"%[str(input), str(slice_start), str(slice_end)])
		input = input.slice(slice_start, slice_end)
		input_changed(input)
	
	func _to_string():
		return "SimCon(to_index:%d, slice(%d-%d))"%[to_index, slice_start, slice_end]
