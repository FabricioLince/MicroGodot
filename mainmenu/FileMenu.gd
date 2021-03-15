extends MenuButton

var design_manager
var file_dialog : FileDialog

enum  FileOptions { NEW, OPEN, SAVE, SAVE_AS, QUIT }
const accelerators = {
	FileOptions.NEW : (KEY_MASK_CTRL | KEY_N),
	FileOptions.OPEN : (KEY_MASK_CTRL | KEY_O),
	FileOptions.SAVE : (KEY_MASK_CTRL | KEY_S),
	FileOptions.SAVE_AS : (KEY_MASK_CTRL | KEY_MASK_SHIFT | KEY_S),
	FileOptions.QUIT : (KEY_MASK_CTRL | KEY_Q),
}
const captions = {
	FileOptions.NEW : "New",
	FileOptions.OPEN : "Open",
	FileOptions.SAVE : "Save",
	FileOptions.SAVE_AS : "Save as",
	FileOptions.QUIT : "Quit",
}

func _ready():
	var menu = self.get_popup()
	for i in range(FileOptions.values().size()):
		menu.add_item(captions[i], i, accelerators[i])
	
	menu.connect("id_pressed", self, "on_menu_id_pressed")

func on_menu_id_pressed(id):
	match(id):
		FileOptions.NEW:
			check_save_then_do(design_manager, "new_design")
		FileOptions.OPEN:
			check_save_then_do(self, "open_file")
		FileOptions.SAVE:
			design_manager.save_design()
		FileOptions.SAVE_AS:
			design_manager.save_design_as()
		FileOptions.QUIT:
			check_save_then_do(get_tree(), "quit")

func open_file():
	file_dialog.prompt_select_file()
	var path = yield(file_dialog, "done_selecting")
	if path:
		design_manager.load_from_path(path)
func check_save_then_do(object, function):
	design_manager.check_needs_save()
	var cancel = yield(design_manager, "done_checking")
	if not cancel:
		object.call(function)


