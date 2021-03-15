extends Node2D

onready var InfoPanel = $CanvasLayer/InfoPanel
onready var Board = $Board
onready var camera = $Camera2D
onready var Mouse = $Mouse
onready var DesignManager = $DesignManager
onready var Selector = $Selector

func _ready():
	OS.window_maximized = true
	
	Mouse.board = Board
	Mouse.camera = camera
	Mouse.selector = $Selector
	Mouse.canvas_layer = $CanvasLayer
	
	camera.board = Board
	
	Instantiator.board = Board
	Instantiator.popup_dialog = $CanvasLayer/PopupDialog
	Instantiator.design_manager = DesignManager
	
	DesignManager.file_dialog = $CanvasLayer/FileDialog
	DesignManager.board = Board
	DesignManager.camera = camera
	DesignManager.popup_dialog = $CanvasLayer/PopupDialog
	
	Selector.popup_dialog = $CanvasLayer/PopupDialog
	Selector.info_panel = InfoPanel
	
	ContextMenuCreator.canvas_layer = $CanvasLayer
	ContextMenuCreator.selector = Selector
	ContextMenuCreator.Mouse = Mouse
	
	$CanvasLayer.file_menu.design_manager = DesignManager
	
	var _a = get_tree().connect("files_dropped", self, "files_dropped")
	
	#Instantiator.spawn_complex_chip("8 bit adder", Vector2(0, 0))
	DesignManager.load_from_path("res://saves/testes/inner_constant.chip")
	#Instantiator.spawn_script_chip("Splitter", Vector2.ZERO)
	#inverter_chain(0)

func files_dropped(files: PoolStringArray, _screen: int):
	DesignManager.load_safe(files[0])

func inverter_chain(amount):
	var initial_pos = Vector2(-96, 0)
	var delta = Vector2(256, 0)
	var button = Instantiator.spawn_button("B", initial_pos)
	var last = button
	for _i in range(amount):
		initial_pos += delta
		var c = Instantiator.spawn_script_chip("res://chips/Inverter.gd", initial_pos)
		var current = c.connectors.in_connectors[0]
		Instantiator.connect_directly(last, current)
		last = c.connectors.out_connectors[0]
	initial_pos += delta
	var led = Instantiator.spawn_led("L", initial_pos)
	Instantiator.connect_directly(last, led)
	
func foo2():
	var wait = 0.3
	
	var adder = Instantiator.spawn_complex_chip("res://saves/8 bit adder.chip", Vector2(0, 0))
	yield(get_tree().create_timer(wait), "timeout")
	
	var sum = Instantiator.spawn_hexdisplay("SUM", Vector2(200, 0))
	yield(get_tree().create_timer(wait), "timeout")
	sum.set("size_index", 1)
	yield(get_tree().create_timer(wait), "timeout")
	Instantiator.connect_directly(sum, adder.connectors.out_connectors[0])
	yield(get_tree().create_timer(wait), "timeout")
	
	var cout = Instantiator.spawn_led("COUT", Vector2(200, -100))
	yield(get_tree().create_timer(wait), "timeout")
	Instantiator.connect_directly(cout, adder.connectors.out_connectors[1])
	yield(get_tree().create_timer(wait), "timeout")
	
	var hb = Instantiator.spawn_hexinput("B", Vector2(-200, -100))
	yield(get_tree().create_timer(wait), "timeout")
	hb.set("size_index", 1)
	yield(get_tree().create_timer(wait), "timeout")
	Instantiator.connect_directly(hb, adder.connectors.in_connectors[2])
	yield(get_tree().create_timer(wait), "timeout")
	
	var ha = Instantiator.spawn_hexinput("A", Vector2(-200, 00))
	yield(get_tree().create_timer(wait), "timeout")
	ha.set("size_index", 1)
	yield(get_tree().create_timer(wait), "timeout")
	Instantiator.connect_directly(ha, adder.connectors.in_connectors[1])
	yield(get_tree().create_timer(wait), "timeout")
	
	var cin = Instantiator.spawn_button("CIN", Vector2(-200, 100))
	yield(get_tree().create_timer(wait), "timeout")
	Instantiator.connect_directly(cin, adder.connectors.in_connectors[0])
	
	#DesignManager.load_from_path("res://saves/b.chip")
