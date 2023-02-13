extends "res://components/input/OutputOnly.gd"

signal update_info_panel()

onready var digits = $Control

var value := 0 setget set_value
func set_value(v:int):
	match(show_value_as):
		Global.ShowValueKind.PURE_VALUE:
			while v < 0: v += self.max_value
			value = v % self.max_value
			digits.set_pure_value(value)
			output = Signal.List.from_number(value, bits)
		Global.ShowValueKind.TWOS_COMPLEMENT:
			output = Signal.List.from_twos_complement(v, bits)
			value = Signal.List.negative_equivalent(v, bits)
			digits.set_twos_complement_value(value)
	send_output()
	
var max_value : int setget set_mv, get_max_value
func set_mv(_v): pass
func get_max_value() -> int: return Signal.Utils.int_pow(2, bits)

var bits := 4 setget set_bits
func set_bits(b:int):
	bits = b
	size_index = sizes.bsearch(bits)
	set_connector_sizes([bits])
	connector = connectors.out_connectors[0]
	digits.set_input_size(size_index)
	set_value(value)
	emit_signal("update_info_panel")
	
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	set_shape_extents(digits.rect_size/2)
	area.position = digits.get_rect().get_center()
	build_selection_line()

var output = []
var connector

func _ready():
	set_connector_sizes([4])
	connector = connectors.out_connectors[0]

func get_output():
	return output

func component_name():
	return "HexInput"

func get_info():
	var info = .get_info()
	info.value = value
	info.bits = bits
	info.show_value_as = Global.ShowValueKind.keys()[show_value_as]
	return info
func from_info(info):
	.from_info(info)
	if info.has("bits"):
		self.bits = info.bits
	if info.has("show_value_as"):
		self.show_value_as = Global.show_value_kind_from_string(info.show_value_as)
	set_value(int(info.value))

func get_properties():
	var p = .get_properties()
	p.append({
		kind = "hex_value",
		label = "Value",
		name = "value",
		size = bits,
	})
	p.append({
		kind = "list",
		label = "Bits",
		items = sizes,
		name = "size_index"
	})
	p.append({
		kind = "list",
		label = "Show as",
		items = sv_caption,
		name = "show_value_as"
	})
	return p

const sizes = [4, 8, 12, 16]
var size_index := 0 setget set_size_index
func set_size_index(i:int):
	size_index = i
	self.bits = sizes[i]


var sv_caption = ["Pure value", "Two's complement"]
var show_value_as = Global.ShowValueKind.PURE_VALUE setget set_sva
func set_sva(sva):
	show_value_as = sva
	set_value(value)
