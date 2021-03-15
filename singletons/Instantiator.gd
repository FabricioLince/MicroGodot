extends Node2D

const Button = preload("res://components/input/Button.tscn")
const HexInput = preload("res://components/input/HexInput.tscn")
const HexDisplay = preload("res://components/output/HexDisplay.tscn")
const Led = preload("res://components/output/Led.tscn")
const Connection = preload("res://connector/Connection.tscn")
const LogicGateKind = preload("res://chips/Logic.gd").Kind
const ScriptChip = preload("res://components/chips/ScriptChip/ScriptChip.tscn")
const ComplexChip = preload("res://components/chips/ComplexChip.tscn")

var board
var popup_dialog
var design_manager

func spawn_labeled_component(prefab, position, label):
	var c = prefab.instance()
	board.add_child(c)
	c.name = label
	c.label = label
	c.set_position(position)
	return c
func spawn_hexdisplay(label, position):
	return spawn_labeled_component(HexDisplay, position, label)
func spawn_hexinput(label, position):
	return spawn_labeled_component(HexInput, position, label)
func spawn_button(label, position):
	return spawn_labeled_component(Button, position, label)
func spawn_led(label, position):
	return spawn_labeled_component(Led, position, label)

func secure_spawn_io_by_type(type, label, position):
	match(type):
		"Button":
			return spawn_button(label, position)
		"Led":
			return spawn_led(label, position)
		"HexInput":
			return spawn_hexinput(label, position)
		"HexDisplay":
			return spawn_hexdisplay(label, position)
func spawn_io_by_type(type, label, position):
	var io = secure_spawn_io_by_type(type, label, position)
	if io: return io
	push_error("Couldn't spawn IO type '%s'"%type)

func spawn_logic_chip(kind, position):
	var chip = spawn_script_chip("Logic", position)
	chip.set("Kind", kind)
	return chip

func spawn_script_chip(path, position):
	var chip = ScriptChip.instance()
	chip.position = position
	board.add_child(chip)
	if path:
		chip.file_path = path
	return chip

func spawn_complex_chip(path, position):
	var chip = ComplexChip.instance()
	chip.position = position
	chip.design_manager = design_manager
	board.add_child(chip)
	if path:
		chip.load_script(path)
	return chip

func secure_spawn_chip_by_type(type, path, position):
	match(type):
		"ScriptChip":
			return spawn_script_chip(path, position)
		"ComplexChip":
			return spawn_complex_chip(path, position)
func spawn_chip_by_type(type, path, position):
	var chip = secure_spawn_chip_by_type(type, path, position)
	if chip: return chip
	push_error("Couldn't spawn Chip type '%s'"%type)

func spawn_component_from_info(info):
	if info.has("label"):
		var io = spawn_io_by_type(info.type, info.label, info.position)
		if io: 
			io.from_info(info)
			return io
	var chip = spawn_chip_by_type(info.type, info.path, info.position)
	if chip:
		chip.from_info(info)
		return chip

func copy(object):
	return spawn_component_from_info(object.get_info())

func connect_directly(con_a, con_b):
	var size_a = get_bit_size(con_a)
	var size_b = get_bit_size(con_b)
	if size_a == 0 or size_b == 0:
		# no connector found
		return
	if size_a != size_b:
		print("Can't connect (%s) and (%s)"%[con_a.description(), con_b.description()])
		popup_dialog.prompt_warning("Incompatible bit sizes")
		return
	if get_con_kind(con_a) == get_con_kind(con_b):
		print("Can't connect two %s connectors"%[get_con_kind(con_a)])
		if get_con_kind(con_a) == 0:
			popup_dialog.prompt_warning("Can't connect two input connectors")
		else:
			popup_dialog.prompt_warning("Can't connect two output connectors")
		return
		
	var c1 = Connection.instance()
	board.add_child(c1)
	c1.connect_on(con_a)
	c1.connect_on(con_b)
	if c1.check_for_deletion():
		print("Connection creation error")
	return c1

func get_bit_size(obj):
	if obj:
		if obj.get("is_connector"):
			return obj.size
		else:
			return get_bit_size(obj.get("connector"))
	return 0
func get_con_kind(obj):
	if obj:
		if obj.get("is_connector"):
			return obj.kind
		else:
			return get_con_kind(obj.get("connector"))
