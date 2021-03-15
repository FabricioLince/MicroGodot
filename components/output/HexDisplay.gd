	extends "res://components/output/InputOnly.gd"

var connector
var last_input

var value = null setget set_value
func set_value(v):
	#print("setting value: ", v)
	if v == null:
		$Sprite/Label.text = "U"
		$Sprite.modulate = Global.signal_to_color(-1)
	else:
		value = v
		$Sprite/Label.text = ("%0"+str(bits/4)+"X")%(value)
		$Sprite.modulate = Color.white

var bits = 4 setget set_bits
func set_bits(b):
	bits = b
	size_index = sizes.bsearch(bits)
	set_connector_sizes([bits])
	connector = connectors.in_connectors[0]

func _ready():
	set_connector_sizes([4])
	connector = connectors.in_connectors[0]
	self.value = null

func set_input(signals, _index=0, _size=null):
	# child classes must implement this functions to 
	# receive input signals from input connectors
	#print("setting input: ", signals)
	last_input = signals
	var pure_value = Signal.List.to_number(signals)
	if pure_value < 0:
		self.value = null
		return
	match(show_value_as):
		Global.ShowValueKind.PURE_VALUE:
			self.value = pure_value
		Global.ShowValueKind.TWOS_COMPLEMENT:
			self.value = Signal.List.to_twos_complement(signals)

func get_info():
	var info = .get_info()
	info.bits = bits
	info.show_value_as = Global.ShowValueKind.keys()[show_value_as]
	return info
func from_info(info):
	.from_info(info)
	if info.has("bits"):
		self.bits = info.bits
	if info.has("show_value_as"):
		self.show_value_as = Global.show_value_kind_from_string(info.show_value_as)

func get_properties():
	var p = .get_properties()
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


var sizes = [4, 8, 12, 16]
var size_index = 0 setget set_size_index
func set_size_index(i):
	size_index = i
	self.bits = sizes[i]


var sv_caption = ["Pure value", "Two's complement"]
var show_value_as = Global.ShowValueKind.PURE_VALUE setget set_sva
func set_sva(sva):
	show_value_as = sva
	if last_input:
		set_input(last_input)
