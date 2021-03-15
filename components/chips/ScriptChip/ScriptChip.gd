extends "res://components/chips/ChipBase.gd"

const SimChip = preload("res://components/chips/Simulated/ScriptChip.gd")

signal update_info_panel

var file_path setget set_file_path
func set_file_path(path):
	load_script(path)

var chip_behavior

func _process(delta):
	if chip_behavior:
		chip_behavior.loop(delta)

func load_script(path, force_reload=false):
	if file_path == path and not force_reload:
		return
	file_path = path
	var full_path = Global.script_chip_full_path2(path)
	if File.new().file_exists(full_path):
		chip_behavior = SimChip.new()
		chip_behavior.connect("on_label_changed", self, "set_label")
		chip_behavior.connect("on_output_changed", self, "on_behavior_output_changed")
		if chip_behavior.load_script(path):
			initialize_connectors()
		chip_behavior.connect("on_rebuild", self, "initialize_connectors")
	else:
		push_error("'%s' could not be found"%full_path)
		self.label = "ERROR"
		return false

func initialize_connectors():
	connectors.initialize_input_connectors(chip_behavior.input_sizes)
	connectors.set_input_names(chip_behavior.input_names)
	
	connectors.initialize_output_connectors(chip_behavior.output_sizes)
	connectors.set_output_names(chip_behavior.output_names)
	
	emit_signal("update_info_panel")

func set_input(signals, index, _size=null):
	#print("set_input(", signals, ", ", index, ", ", size, ")")
	chip_behavior.set_input(signals, index)

func get_output():
	return chip_behavior.output

func on_behavior_output_changed(_output):
	send_output()

func component_name():
	return "ScriptChip"
func get_info():
	var info = .get_info()
	info.erase("label")
	info.path = file_path
	info.properties = chip_behavior.get_properties_info()
	if info.properties == null:
		info.erase("properties")
	return info
func from_info(info):
	self.file_path = info.path
	if info.has("properties"):
		chip_behavior.set_properties_from_info(info.properties)
	.from_info(info)

func description():
	return chip_behavior.description()

func get_properties():
	return chip_behavior.get_properties()

	

func get(prop_name):
	if chip_behavior:
		var prop_value = chip_behavior.get(prop_name)
		if prop_value != null: return prop_value
	return .get(prop_name)
func set(prop_name, prop_value):
	if chip_behavior and chip_behavior.set(prop_name, prop_value):
		return
	.set(prop_name, prop_value)
