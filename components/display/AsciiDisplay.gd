extends "res://components/Component.gd"

const POS_INDEX = 0
const ASCII_INDEX = 4
const SET_INDEX = 12

var pos := 0
var ascii : int
var inc_on_set := true

var labels := []
onready var grid = $NinePatchRect/GridContainer
const char_amount = 16

func _ready():
	set_label("Ascii Display")
	connectors.initialize([4, 8, 1], [])
	connectors.set_input_names(["pos", "ascii", "set"])
	for l in grid.get_children():
		l.text = ""


func set_input(signals:Array, index:int, _size:int):
	match index:
		POS_INDEX:
			pos = Signal.List.to_number(signals)
		ASCII_INDEX:
			ascii = Signal.List.to_number(signals)
		SET_INDEX:
			if signals[0] == Signal.Kind.HIGH:
				if pos < 0 or pos >= char_amount:
					return
				if ascii < 0:
					return
#				print("setting %d to %d"%[pos, ascii])
				grid.get_child(pos).text = PoolByteArray([ascii]).get_string_from_ascii()
				if inc_on_set:
					pos = (pos+1)%char_amount
			

func component_name() -> String:
	return "AsciiDisplay"
func description() -> String:
	return "Ascii Display"

func get_info() -> Dictionary:
	var info := .get_info()
	info.erase("label")
	info.inc_on_set = inc_on_set
	return info
func from_info(info:Dictionary):
	.from_info(info)
	inc_on_set = info.get("inc_on_set", true)

func get_properties() -> Array:
	return [
		{
			kind = "toggle",
			label = "Increment on set",
			name = "inc_on_set"
		}
	]
