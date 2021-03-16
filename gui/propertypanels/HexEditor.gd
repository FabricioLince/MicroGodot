extends PanelContainer

signal value_changed(new_int)

onready var spin_box = $Container/SpinBox
onready var line_edit = $Container/SpinBox.get_line_edit()

var hex = "0" setget set_hex
var value = 0 setget set_value, get_value

func set_value(v): spin_box.value = v
func get_value(): return spin_box.value

func _ready():
	var _a = spin_box.connect("value_changed", self, "on_value_changed")
	_a = line_edit.connect("text_changed", self, "on_text_changed")
	spin_box.min_value = -1

func on_value_changed(new_value):
	#print("new value = ", new_value)
	if new_value < 0:
		spin_box.value = spin_box.max_value - 1
	elif new_value >= spin_box.max_value:
		spin_box.value = 0
	else:
		hex = "%X"%int(new_value)
		line_edit.text = hex
		emit_signal("value_changed", int(new_value))

func on_text_changed(new_text):
	var caret = line_edit.caret_position
	#print("new text = ", new_text)
	var value = ("0x"+new_text).hex_to_int()
	if value > spin_box.max_value:
		new_text = new_text.substr(1, -1) # chops first character
		value = ("0x"+new_text).hex_to_int()
	spin_box.value = value
	#print("new value from hex = ", self.value)
	line_edit.caret_position = caret

func set_hex(h):
	spin_box.value = ("0x"+str(h)).hex_to_int()


var label setget set_label
func set_label(l):
	$Container/Label.text = l
	label = l
