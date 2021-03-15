extends PanelContainer

onready var option = $VBoxContainer/OptionButton

signal index_changed(index)

var items = [] setget set_items
func set_items(new_items):
	items = new_items
	var p = option
	p.clear()
	match typeof(new_items):
		TYPE_ARRAY:
			for i in range(items.size()):
				p.add_item(str(items[i]), i)
		TYPE_DICTIONARY:
			for i in items:
				p.add_item(str(items[i]), i)

var index_chosen = 0 setget set_index_chosen
func set_index_chosen(new_index):
	index_chosen = new_index
	option.selected = new_index

var label = "Select" setget set_label
func set_label(l):
	$VBoxContainer/Label.text = l
	label = l

func _on_OptionButton_item_selected(index):
	index_chosen = index
	emit_signal("index_changed", index)
