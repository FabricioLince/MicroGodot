extends PanelContainer

signal state_changed(new_state)

var state setget set_state, get_state
func set_state(s):
	$CheckButton.pressed = s
func get_state():
	return $CheckButton.pressed

var label setget set_label
func set_label(l):
	$CheckButton.text = l
	label = l


func _on_CheckButton_toggled(button_pressed):
	state = button_pressed
	emit_signal("state_changed", state)
