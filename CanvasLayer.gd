extends CanvasLayer

enum InputComponents {Button, HexInput}
enum OutputComponents {Led, HexDisplay}
enum UtilChips {Inverter, Conversor, Splitter, Counter, Clock, Bus}

export (Theme) var theme 

onready var Mouse = get_node("../Mouse")
onready var Board = get_node("../Board")
onready var file_dialog = $FileDialog
onready var file_menu = $TopBar/MainMenu/FileMenu
onready var insert_menu = $TopBar/MainMenu/InsertMenu
onready var info_panel = $InfoPanel
onready var context_menu = $ContextMenu
onready var insert_popup = $InsertPopup

var insert_menu_items setget set_none, get_insert_menu_items
func set_none(_a): pass

func _ready():
	file_menu.file_dialog = file_dialog
	prepare_popup($InsertPopup, self.insert_menu_items)
	context_menu.connect("hide", self, "on_hide_context_menu")

func set_theme_on_children(node:Control):
	if node == null: return
	node.theme = theme
	for c in node.get_children():
		set_theme_on_children(c)

func get_insert_menu_items():
	if not insert_menu_items:
		config_insert_menu_items()
	return insert_menu_items
func config_insert_menu_items():
	insert_menu_items = [
		{
			label = "Input",
			kind = "submenu",
			callback = {target = self, method = "on_input_pressed"},
			items = []
		},
		{
			label = "Output",
			kind = "submenu",
			callback = {target = self, method = "on_output_pressed"},
			items = []
		},
		{
			label = "Chip",
			kind = "submenu",
			items = [{
				label = "Logic",
				kind = "submenu",
				items = [],
				callback = {target = self, method = "on_logic_chip_pressed"}
			},
			{
				label = "Utils",
				kind = "submenu",
				items = [],
				callback = {target = self, method = "on_util_chip_pressed"}
			},
			{
				label = "Complex",
				kind = "item",
				id = 2
			}],
			callback = {target = self, method = "on_chip_menu_pressed"}
		}
	]
	for i in range(InputComponents.size()):
		insert_menu_items[0].items.append({
			label = InputComponents.keys()[i],
			kind = "item",
			id = InputComponents.values()[i]
		})
	for i in range(OutputComponents.size()):
		insert_menu_items[1].items.append({
			label = OutputComponents.keys()[i],
			kind = "item",
			id = OutputComponents.values()[i]
		})
	for i in range(Instantiator.LogicGateKind.size()):
		insert_menu_items[2].items[0].items.append({
			label = Instantiator.LogicGateKind.keys()[i],
			id = Instantiator.LogicGateKind.values()[i],
			kind = "item"
		})
	for i in UtilChips.values():
		insert_menu_items[2].items[1].items.append({
			label = UtilChips.keys()[i], 
			id = i,
			kind = "item"
		})


func on_input_pressed(id):
	#print("Pressed ", InputComponents.keys()[id])
	match(id):
		InputComponents.Button:
			var b = Instantiator.spawn_button("B", Vector2.ZERO)
			Mouse.holding = b
		InputComponents.HexInput:
			var h = Instantiator.spawn_hexinput("H", Vector2.ZERO)
			Mouse.holding = h
func on_output_pressed(id):
	#print("Pressed ", OutputComponents.keys()[id])
	match(id):
		OutputComponents.Led:
			var l = Instantiator.spawn_led("L", get_global_mouse_position())
			Mouse.holding = l
		OutputComponents.HexDisplay:
			var h = Instantiator.spawn_hexdisplay("H", get_global_mouse_position())
			Mouse.holding = h

func on_logic_chip_pressed(id):
	var chip = Instantiator.spawn_logic_chip(id, get_global_mouse_position())
	Mouse.holding = chip


func on_util_chip_pressed(id):
	match(id):
		UtilChips.Inverter:
			var c = Instantiator.spawn_script_chip("Inverter", get_global_mouse_position())
			Mouse.holding = c
		UtilChips.Conversor:
			var c = Instantiator.spawn_script_chip("Conversor", get_global_mouse_position())
			Mouse.holding = c
		UtilChips.Splitter:
			var c = Instantiator.spawn_script_chip("Splitter", get_global_mouse_position())
			Mouse.holding = c
		UtilChips.Counter:
			var c = Instantiator.spawn_script_chip("Counter", get_global_mouse_position())
			Mouse.holding = c
		UtilChips.Clock:
			var c = Instantiator.spawn_script_chip("Clock", get_global_mouse_position())
			Mouse.holding = c
		UtilChips.Bus:
			var c = Instantiator.spawn_script_chip("Bus", get_global_mouse_position())
			Mouse.holding = c

func on_chip_menu_pressed(id):
	#print("chip menu ", id)
	if id == 2:
		file_dialog.prompt_select_file()
		var path = yield(file_dialog, "done_selecting")
		if path: 
			path = Global.complex_chip_local_path(path)
			var c = Instantiator.spawn_complex_chip(path, Vector2())
			Mouse.holding = c
	
func get_global_mouse_position(): return Vector2.ZERO


func prepare_popup(popup_menu:PopupMenu, items):
	popup_menu.clear()
	for item in items:
		match item.kind:
			"submenu":
				var submenu = PopupMenu.new()
				prepare_popup(submenu, item.items)
				popup_menu.add_child(submenu)
				popup_menu.add_submenu_item(item.label, submenu.name)
				var callback = item.get("callback")
				if callback:
					submenu.connect("id_pressed", callback.target, callback.method)
			"item":
				popup_menu.add_item(item.label, item.id)

func show_insert_menu(position):
	$InsertPopup.rect_position = position
	$InsertPopup.popup()

func show_context_menu(position, context_menu_data):
	context_menu.rect_position = position
	var menu = context_menu_data
	context_menu.connect("id_pressed", 
		menu.callback.target, 
		menu.callback.method, 
		menu.callback.args)
	prepare_popup(context_menu, menu.items)
	context_menu.popup()
func on_hide_context_menu():
	for c in context_menu.get_signal_connection_list("id_pressed"):
		context_menu.disconnect("id_pressed", c.target, c.method)
