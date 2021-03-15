extends PanelContainer

var label setget set_label, get_label
func set_label(l):
	$Button.text = l
func get_label(): return $Button.text

var callback

func _on_Button_pressed():
	if callback is FuncRef and callback.is_valid():
		callback.call_func()
