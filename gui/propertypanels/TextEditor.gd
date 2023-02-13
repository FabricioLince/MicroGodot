extends PanelContainer

signal text_changed(new_text)
signal hex_changed(new_hex)

var text := "" setget set_text
func set_text(t:String):
	text = t
	$Container/LineEdit.text = t

var label : String setget set_label
func set_label(l:String):
	$Container/Label.text = l
	label = l

var value_as_hex setget set_value_as_hex, get_value_as_hex
func set_value_as_hex(v):
	self.text = "%X"%v
func get_value_as_hex():
	if text.begins_with("-"):
		var t := text.substr(1)
		if not t.is_valid_hex_number():
			return 0
		return ("-0x"+t).hex_to_int()
	if not text.is_valid_hex_number():
		return 0
	return ("0x"+text).hex_to_int()

func _on_LineEdit_text_changed(new_text):
	text = new_text
	emit_signal("text_changed", new_text)
	emit_signal("hex_changed", get_value_as_hex())
