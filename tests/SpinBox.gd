extends SpinBox

signal int_changed(new_int)

var hex = 0 setget set_hex

func _ready():
	var _a = connect("value_changed", self, "on_value_changed")
	_a = get_line_edit().connect("text_changed", self, "on_text_changed")

func on_value_changed(new_value):
	print("new value = ", new_value)
	get_line_edit().text = "%X"%int(new_value)
	emit_signal("int_changed", int(new_value))

func on_text_changed(new_text):
	var caret = get_line_edit().caret_position
	print("new text = ", new_text)
	value = ("0x"+new_text).hex_to_int()
	print("new value from hex = ", self.value)
	get_line_edit().caret_position = caret

func set_hex(h):
	value = ("0x"+str(h)).hex_to_int()
