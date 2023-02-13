extends "res://components/output/InputOnly.gd"

onready var sprite := $Sprite as Control
onready var display := $Sprite/Label as Label

var connector
var last_input

var value = null setget set_value
func set_value(v):
	#print("setting value: ", v)
	if v == null:
		display.text = "U"
		sprite.modulate = Global.signal_to_color(-1)
	else:
		value = v
		display.text = ("%0"+str(bits/4)+"X")%(value)
		sprite.modulate = Color.white

var bits := 4 setget set_bits
func set_bits(b:int):
	bits = b
	size_index = sizes.bsearch(bits)
	set_connector_sizes([bits])
	connector = connectors.in_connectors[0]
	match bits:
		4:
			set_width(64)
		8:
			set_width(80)
		12:
			set_width(106)
		16:
			set_width(132)

func set_width(w:int):
	sprite.rect_size.x = w
	set_shape_extents(sprite.rect_size/2)
	area.position = sprite.get_rect().get_center()
	$SelectionLine.position = area.position
	build_selection_line()

func _ready():
	set_connector_sizes([4])
	connector = connectors.in_connectors[0]
	self.value = null

func set_input(signals:Array, _index:=0, _size=null):
	# child classes must implement this functions to 
	# receive input signals from input connectors
	#print("setting input: ", signals)
	last_input = signals
	var pure_value = Signal.List.to_number(signals)
	if pure_value < 0:
		set_value(null)
		return
	match(show_value_as):
		Global.ShowValueKind.PURE_VALUE:
			set_value(pure_value)
		Global.ShowValueKind.TWOS_COMPLEMENT:
			set_value(Signal.List.to_twos_complement(signals))

func get_info() -> Dictionary:
	var info := .get_info()
	info.bits = bits
	info.show_value_as = Global.ShowValueKind.keys()[show_value_as]
	return info
func from_info(info:Dictionary):
	.from_info(info)
	if info.has("bits"):
		self.bits = info.bits
	if info.has("show_value_as"):
		self.show_value_as = Global.show_value_kind_from_string(info.show_value_as)

func get_properties() -> Array:
	var p := .get_properties()
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

func component_name():
	return "HexDisplay"


const sizes := [4, 8, 12, 16]
var size_index := 0 setget set_size_index
func set_size_index(i:int):
	size_index = i
	self.bits = sizes[i]


const sv_caption = ["Pure value", "Two's complement"]
var show_value_as = Global.ShowValueKind.PURE_VALUE setget set_sva
func set_sva(sva):
	show_value_as = sva
	if last_input:
		set_input(last_input)
