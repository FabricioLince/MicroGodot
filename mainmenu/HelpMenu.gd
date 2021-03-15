extends MenuButton

var design_manager
var file_dialog : FileDialog

enum  HelpOptions { TUTORIAL, MANUAL }
const accelerators = {
	HelpOptions.TUTORIAL : 0,
	HelpOptions.MANUAL : 1,
}
const captions = {
	HelpOptions.TUTORIAL : "Tutorial",
	HelpOptions.MANUAL : "Manual",
}

func _ready():
	var menu = self.get_popup()
	for i in range(HelpOptions.values().size()):
		menu.add_item(captions[i], i, accelerators[i])
	
	menu.connect("id_pressed", self, "on_menu_id_pressed")

func on_menu_id_pressed(id):
	match(id):
		HelpOptions.TUTORIAL:
			pass
		HelpOptions.MANUAL:
			pass

