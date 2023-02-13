extends "res://components/chips/ScriptChip/ScriptChipBase.gd"

var file_dialog

var file_prop = create_property("File", PropertyKind.TEXT, "")
var button_prop = create_property("Choose File", PropertyKind.BUTTON, "open_file_dialog")
var addr_size_prop = create_property("Address Size", PropertyKind.LIST, 0, {items=sizes} )
var data_size_prop = create_property("Data Size", PropertyKind.LIST, 0, {items=sizes} )

const sizes = [4, 8, 12, 16]
var input_spec := {addr=4}
var output_spec := {data=4}

var data := []

func on_load():
	file_dialog = node.get_node("/root/Editor/CanvasLayer/FileDialog")
	set_label("Rom Reader")

func on_set_input():
	var addr := Signal.List.to_number(get_input_v())
	if addr < 0 or addr >= data.size():
		set_output_v(Signal.List.repeat(Signal.Kind.UNDEFINED, output_spec.data))
	else:
		set_output_v(Signal.List.from_number(data[addr], output_spec.data))

func on_property_changed(prop:Dictionary):
	if prop.name == "File":
		load_file(prop.value)
	else:
		input_spec.addr = sizes[addr_size_prop.value]
		output_spec.data = sizes[data_size_prop.value]
		rebuild()
		on_set_input()

func open_file_dialog():
#	print("Opening dialog...")
	file_dialog.prompt_select_file()
	var path = yield(file_dialog, "done_selecting")
	load_file(path)


func load_file(path:String):
#	print("Loading ", path)
	var file := File.new()
	file.open(path, File.READ)
	if file.is_open():
		file_prop.value = path
		var contents := file.get_as_text()
		file.close()
		
		data.clear()
		contents = contents.replace("\n", " ")
#		print(contents.split(" ", false))
		for x in contents.split(" ", false):
			var s : String = "0x%s"%x
			if s.is_valid_hex_number(true):
				data.append(s.hex_to_int())
		on_set_input()
		set_label("Rom Reader\n%s%s"%[""if path.length()<20 else "..", (path.substr(path.length()-20))])
	
	
