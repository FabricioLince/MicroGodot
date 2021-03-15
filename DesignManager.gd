extends Node2D

signal done_checking(cancel)
signal done_saving

var file_dialog 
var popup_dialog
var design_file_path
var board setget set_board
var camera
onready var title_panel = get_node("/root/Editor/CanvasLayer/TopBar/TitlePanel")
onready var title_label = get_node("/root/Editor/CanvasLayer/TopBar/TitlePanel/Label")

var needs_save = false

func new_design():
	board.clear_all()
	design_file_path = null
	title_panel.hide()
	needs_save = false

func save_design():
	if design_file_path:
		save_on_path(design_file_path)
	else:
		save_design_as()

func save_design_as():
	file_dialog.prompt_save_file()
	var path = yield(file_dialog, "done_selecting")
	if path:
		save_on_path(path)

func save_on_path(path):
	design_file_path = path
	var content = board.serialize_content()
	
	if FileCache.save_on(path, content):
		set_title_text(path)
		needs_save = false
		print("Saved on path: ", design_file_path)
	else:
		print("error saving ", design_file_path)
	emit_signal("done_saving")

func load_from_path(path, clear_board=true):
	#print("DesignManager:load_from_path('%s')"%[path])
	var content = FileCache.load_from(path)
	
	if content:
		if clear_board:
			board.clear_all()
			yield(board, "done_clearing")
		design_file_path = path
	
		board.read_serialized_content(content)
		yield(board, "done_loading")
		camera.center_components(board.components)
		print("Loaded from path: ", path)
		
		set_title_text(path)
		needs_save = false
	else:
		popup_dialog.prompt_warning("'%s' couldn't be open"%path)

func set_board(b):
	board = b
	board.connect("modification", self, "_on_board_modification")
func _on_board_modification():
	if design_file_path:
		if not title_label.text.ends_with("*"):
			title_label.text += "*"
	needs_save = true

func set_title_text(text):
	title_panel.show()
	title_panel.get_node("Label").text = Global.complex_chip_local_path(text)
	
func check_needs_save():
	if needs_save:
		popup_dialog.prompt("Current Design isn't saved", ["Save", "Discard", "Cancel"])
		var b = yield(popup_dialog, "button_pressed")
		match b:
			0:
				save_design()
				yield(self, "done_saving")
			2:
				emit_signal("done_checking", true)
				return
	yield(get_tree(), "idle_frame")
	emit_signal("done_checking", false)

func load_safe(path):
	check_needs_save()
	var cancel = yield(self, "done_checking")
	if not cancel:
		load_from_path(path)
