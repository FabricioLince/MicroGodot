extends VBoxContainer

const Toggle = preload("res://gui/propertypanels/Toggle.tscn")
const TextEditor = preload("res://gui/propertypanels/TextEditor.tscn")
const DropDown = preload("res://gui/propertypanels/DropDown.tscn")
const ButtonPanel = preload("res://gui/propertypanels/Button.tscn")
const HexEditor = preload("res://gui/propertypanels/HexEditor.tscn")

var showing_for = null
var panels = []

func _process(_delta):
	if showing_for == null:
		hide_info()

func hide_info():
	if showing_for and showing_for.has_signal("update_info_panel"):
		showing_for.disconnect("update_info_panel", self, "show_info_for")
	showing_for = null
	for p in $Properties.get_children():
		p.queue_free()
	panels.clear()
	hide()
	set_process(false)

func show_info_for(object):
	#if showing_for or panels.size() > 0:
	hide_info()
	yield(get_tree(), "idle_frame")
	showing_for = object
	show_title_for(object)
	
	if showing_for.has_method("get_properties"):
		for p in showing_for.get_properties():
			match(p.kind):
				"text":
					create_text_editor(p.label, p.name)
				"toggle":
					create_toggle(p.label, p.name)
				"hex_value":
					create_hex_editor(p.label, p.name, pow(2, p.size))
				"list":
					create_drop_down(p.label, p.items, p.name)
				"button":
					create_button(p.label, p.callback)
	else:
		print("selected object has no properties")
	
	show()
	set_process(true)
	if showing_for.has_signal("update_info_panel"):
		showing_for.connect("update_info_panel", self, "show_info_for", [showing_for])
		#showing_for.connect("update_info_panel", self, "refresh")
	
	# for some reason, when show info for multiple objects
	# the rapid calls to this function in causing a desync 
	# between the panels in the panels array and the panels
	# children of $Properties
	var i = 0
	while i < $Properties.get_child_count():
		if not panels.has($Properties.get_child(i)):
			$Properties.remove_child($Properties.get_child(i))
		else:
			i+=1

func refresh():
	var obj = showing_for
	hide_info()
	show_info_for(obj)

func show_title_for(_object):
	var descr = object_description()
	if descr:
		$Title.show()
		$Title/Label.text = descr
	else:
		$Title.hide()

func _on_DeleteButton_pressed():
	if showing_for:
		var descr = object_description()
		if descr:
			var dialog_text = "Delete %s?"%showing_for.description()
			MessageSystem.popup.prompt_confirmation(dialog_text)
			var answer = yield(MessageSystem.popup, "button_pressed")
			if answer == 0:
				showing_for.on_delete()
				hide_info()
		else:
			showing_for.on_delete()
			hide_info()

func has_property(name):
	return showing_for and showing_for.get(name)!=null
func get_property(name):
	return showing_for.get(name)
func _on_property_changed(value, name):
	showing_for.set(name, value)


func create_toggle(label, property_name):
	var toggle = raw_panel(Toggle, label)
	toggle.state = get_property(property_name)
	toggle.connect("state_changed", self, "_on_property_changed", [property_name])
	return toggle

func create_hex_editor(label, property_name, max_value):
	var hex_editor = raw_panel(HexEditor, label)
	hex_editor.spin_box.max_value = max_value
	hex_editor.value = get_property(property_name)
	hex_editor.connect("value_changed", self, "_on_property_changed", [property_name])
	return hex_editor

func create_text_editor(label, property_name):
	var text_editor = raw_panel(TextEditor, label)
	text_editor.text = get_property(property_name)
	text_editor.connect("text_changed", self, "_on_property_changed", [property_name])
	return text_editor


func create_drop_down(label, items, property_name):
	var drop = raw_panel(DropDown, label)
	drop.items = items
	drop.index_chosen = get_property(property_name)
	drop.connect("index_changed", self, "_on_property_changed", [property_name])
	return drop

func create_button(label, callback):
	var button = raw_panel(ButtonPanel, label)
	button.callback = callback
	return button

func raw_panel(Scene, label=null):
	var panel = Scene.instance()
#	if Scene.has_method("instance"):
#		panel = Scene.instance()
#	else:
#		panel = Scene.new()
	$Properties.add_child(panel)
	panels.append(panel)
	if label:
		panel.label = label
	return panel

func object_description():
	if showing_for.has_method("description"):
		return showing_for.description()
