extends Node2D

const Component = preload("res://components/Component.gd")
const Board = preload("res://Board.gd")

const Button = preload("res://components/input/Button.tscn")
const ButtonScript = preload("res://components/input/Button.gd")
const HexInput = preload("res://components/input/HexInput.tscn")
const HexDisplay = preload("res://components/output/HexDisplay.tscn")
const Led = preload("res://components/output/Led.tscn")
const LedScript = preload("res://components/output/Led.gd")
const Connection = preload("res://connector/Connection.tscn")
const LogicGateKind = preload("res://chips/Logic.gd").Kind
const ScriptChip = preload("res://components/chips/ScriptChip/ScriptChip.tscn")
const ComplexChip = preload("res://components/chips/ComplexChip.tscn")
const Bus = preload("res://components/Bus.tscn")
const AsciiDisplay = preload("res://components/display/AsciiDisplay.tscn")

var board : Board
var popup_dialog
var design_manager

func spawn_labeled_component(prefab:PackedScene, position:Vector2, label:String) -> Component:
	var c : Component = prefab.instance()
	board.add_child(c)
	c.name = label
	c.label = label
	c.set_position(position)
	return c
func spawn_hexdisplay(label:String, position:Vector2):
	return spawn_labeled_component(HexDisplay, position, label)
func spawn_hexinput(label:String, position:Vector2):
	return spawn_labeled_component(HexInput, position, label)
func spawn_button(label:String, position:Vector2) -> ButtonScript:
	return spawn_labeled_component(Button, position, label) as ButtonScript
func spawn_led(label:String, position:Vector2) -> LedScript:
	return spawn_labeled_component(Led, position, label) as LedScript


func secure_spawn_io_by_type(type:String, label:String, position:Vector2) -> Component:
	match(type):
		"Button":
			return spawn_button(label, position)
		"Led":
			return spawn_led(label, position)
		"HexInput":
			return spawn_hexinput(label, position)
		"HexDisplay":
			return spawn_hexdisplay(label, position)
	return null

func spawn_io_by_type(type:String, label:String, position:Vector2) -> Component:
	var io := secure_spawn_io_by_type(type, label, position)
	if is_instance_valid(io):
		return io
	push_error("Couldn't spawn IO type '%s'"%type)
	return null

func spawn_logic_chip(kind:int, position:Vector2):
	var chip := spawn_script_chip("Logic", position)
	chip.set("Kind", kind)
	return chip

func spawn_script_chip(path:String, position:Vector2) -> Component:
	var chip : Component = ScriptChip.instance()
	chip.position = position
	board.add_child(chip)
	if path:
		if not chip.set_file_path(path):
			chip.on_delete()
			return null
	return chip

func spawn_complex_chip(path:String, position:Vector2) -> Component:
	var chip : Component = ComplexChip.instance()
	chip.position = position
	board.add_child(chip)
	if path:
		if not chip.load_script(path):
			chip.on_delete()
			return null
	return chip

func secure_spawn_chip_by_type(type:String, path:String, position:Vector2) -> Component:
	match(type):
		"ScriptChip":
			return spawn_script_chip(path, position)
		"ComplexChip":
			return spawn_complex_chip(path, position)
	return null
func spawn_chip_by_type(type:String, path:String, position:Vector2) -> Component:
	var chip := secure_spawn_chip_by_type(type, path, position)
	if is_instance_valid(chip):
		return chip
	push_error("Couldn't spawn Chip type '%s'"%type)
	return null

func spawn_bus() -> Component:
	var bus = Bus.instance()
	board.add_child(bus)
	return bus

func spawn_ascii_display() -> Component:
	var display = AsciiDisplay.instance()
	board.add_child(display)
	return display

func spawn_component_from_info(info:Dictionary) -> Component:
	if info.has("label"):
		var io = spawn_io_by_type(info.type, info.label, info.position)
		if io: 
			io.from_info(info)
			return io
	if info.type == "Bus":
		var bus := spawn_bus()
		bus.from_info(info)
		return bus
	if info.type == "AsciiDisplay":
		var display := spawn_ascii_display()
		display.from_info(info)
		return display
	var chip := spawn_chip_by_type(info.type, info.path, info.position)
	if chip:
		chip.from_info(info)
		return chip
	return null

func copy(object:Component) -> Component:
	return spawn_component_from_info(object.get_info())

func connect_directly(con_a:Node, con_b:Node):
	var size_a := get_bit_size(con_a)
	var size_b := get_bit_size(con_b)
	if size_a == 0 or size_b == 0:
		# no connector found
		if con_b.get("is_bus"):
			con_b = con_b.create_connector_for(con_a)
			size_b = size_a
		else:
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
		
	var c1 := Connection.instance()
	board.add_child(c1)
	c1.connect_on(con_a)
	c1.connect_on(con_b)
	if c1.check_for_deletion():
		print("Connection creation error")
	return c1

func get_bit_size(obj:Node) -> int:
	if is_instance_valid(obj):
		if obj.get("is_connector"):
			return obj.size
		else:
			return get_bit_size(obj.get("connector"))
	return 0
func get_con_kind(obj:Node) -> int: #Connector::Kind
	if is_instance_valid(obj):
		if obj.get("is_connector"):
			return obj.kind
		else:
			return get_con_kind(obj.get("connector"))
	return -1
