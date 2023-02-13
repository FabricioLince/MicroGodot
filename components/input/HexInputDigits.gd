extends HBoxContainer

onready var hex_input = get_parent()

var digits := []
var labels := []

func _ready():
	for _i in range(3):
		var digit := $Unit.duplicate()
		add_child(digit)
	for i in range(4):
		var digit := get_child(i+1)
		move_child(digit, 1)
		digits.append(digit)
		var up := digit.get_node("UpButton") as Button
		up.connect("pressed", self, "_on_button_pressed", [+1, i])
		var down := digit.get_node("DownButton") as Button
		down.connect("pressed", self, "_on_button_pressed", [-1, i])
		var l = digit.get_node("Label")
		labels.append(l)
		l.text = str(i)
	set_input_size(0)

func set_input_size(size_index:int):
	for c in get_children():
		c.hide()
	for i in range(digits.size()):
		if i <= size_index:
			digits[i].show()

const chars = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"]

func set_pure_value(value:int):
	$Signal.hide()
	var txt : String = "%04X"%value
	for i in range(4):
		labels[3-i].text = txt[i]

func set_twos_complement_value(value:int):
	set_pure_value(int(abs(value)))
	$Signal.show()
	$Signal/Label.text = "-" if value < 0 else ("+" if value > 0 else "")

func _on_button_pressed(dir:int, order:int):
	hex_input.value += dir * Signal.Utils.int_pow(16, order)
