extends "res://components/chips/ChipBase.gd"

const SimChip = preload("res://components/chips/Simulated/ScriptChip.gd")

signal update_info_panel()

var file_path : String setget set_file_path
func set_file_path(path:String) -> bool:
	return load_script(path)

var chip_behavior : SimChip

func _process(delta:float):
	if is_instance_valid(chip_behavior):
		chip_behavior.loop(delta)

func load_script(path:String, force_reload:=false) -> bool:
	if file_path == path and not force_reload:
		return false
	file_path = path
	chip_behavior = SimChip.new()
	chip_behavior.node = self as Node
	chip_behavior.connect("on_label_changed", self, "set_label")
	chip_behavior.connect("on_output_changed", self, "on_behavior_output_changed")
	chip_behavior.connect("on_rebuild", self, "initialize_connectors")
	if chip_behavior.load_script(path):
		initialize_connectors()
		return true
	else:
		push_error("'%s' could not be found"%file_path)
		MessageSystem.popup.prompt_warning("'%s' script could not be found"%file_path)
		self.label = "ERROR"
		return false

func initialize_connectors():
	connectors.initialize_input_connectors(chip_behavior.input_sizes)
	connectors.set_input_names(chip_behavior.input_names)
	
	connectors.initialize_output_connectors(chip_behavior.output_sizes)
	connectors.set_output_names(chip_behavior.output_names)
	
	emit_signal("update_info_panel")

func set_input(signals:Array, index:int, _size=null):
	#print("set_input(", signals, ", ", index, ", ", size, ")")
	chip_behavior.set_input(signals, index)

func force_next():
	chip_behavior.force_next()

func get_output() -> Array:
	return chip_behavior.output

func on_behavior_output_changed(_output):
	send_output()

func component_name() -> String:
	return "ScriptChip"
func get_info() -> Dictionary:
	var info := .get_info()
	info.erase("label")
	info.path = file_path
	info.properties = chip_behavior.get_properties_info()
	if info.properties == null:
		info.erase("properties")
	return info
func from_info(info:Dictionary):
	self.file_path = info.path
	if info.has("properties"):
		chip_behavior.set_properties_from_info(info.properties)
	.from_info(info)

func description() -> String:
	if chip_behavior:
		return chip_behavior.description()
	return "'%s' could not be found"%file_path

func get_properties() -> Array:
	if chip_behavior:
		return chip_behavior.get_properties()
	return []

func get(prop_name:String):
	if is_instance_valid(chip_behavior):
		var prop_value = chip_behavior.get(prop_name)
		if prop_value != null: return prop_value
	return .get(prop_name)
func set(prop_name:String, prop_value):
	if is_instance_valid(chip_behavior) and chip_behavior.set(prop_name, prop_value):
		return
	.set(prop_name, prop_value)

func on_delete():
	if is_instance_valid(chip_behavior) and chip_behavior.has_method("on_delete"):
		chip_behavior.on_delete()
	.on_delete()
