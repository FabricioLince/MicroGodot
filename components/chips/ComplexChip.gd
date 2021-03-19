extends "res://components/chips/ChipBase.gd"

const Behavior = preload("res://components/chips/Simulated/ComplexChip.gd")

var file_path setget load_script
var chip_behavior
var output = [] setget set_output, get_output

func _process(delta):
	if chip_behavior:
		chip_behavior.loop(delta)

func load_script(path):
	file_path = path
	var full_path = Global.complex_chip_full_path(path)
	if File.new().file_exists(full_path):
		chip_behavior = Behavior.new(get_tree())
		chip_behavior.connect("on_label_changed", self, "set_label")
		chip_behavior.connect("on_output_changed", self, "set_output")
		if chip_behavior.load_from_path(path):
			initialize_connectors()
		#chip_behavior.connect("on_rebuild", self, "initialize_connectors")
	else:
		push_error("'%s' could not be found"%full_path)
		self.label = "ERROR"
		return false

func initialize_connectors():
	connectors.initialize_input_connectors(chip_behavior.input_sizes)
	connectors.set_input_names(chip_behavior.input_names)
	
	var output_sizes = []
	var output_names = []
	for i in chip_behavior.ordered_output:
		output_sizes.append(i.size)
		output_names.append(i.label)
	connectors.initialize_output_connectors(output_sizes)
	connectors.set_output_names(output_names)

func set_input(signals, index, _size):
	#print("setting input of %s on index %d = %s"%[description(), index, str(signals)])
	chip_behavior.set_input(signals, index)

func set_output(new_output):
	output = new_output
	send_output()
func get_output():
	return output

func description():
	if chip_behavior:
		return get_label()
	return "'%s' couldn't be loaded"%file_path
	#"Complex Chip\n"+get_label()

func component_name():
	return "ComplexChip"
func get_info():
	var info = .get_info()
	info.erase("label")
	info.path = file_path
	info.properties = null#chip_behavior.get_properties_info()
	if info.properties == null:
		info.erase("properties")
	return info
func from_info(info):
	self.file_path = info.path
	if info.has("properties"):
		chip_behavior.set_properties_from_info(info.properties)
	.from_info(info)

func get_properties():
	return [
		{
			kind = "button",
			label = "Open design",
			callback = funcref(self, "open_design")
		}
	]

func open_design():
	DesignManager.load_safe(Global.complex_chip_full_path(file_path))
