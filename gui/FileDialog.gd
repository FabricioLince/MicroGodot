extends FileDialog

signal done_selecting(path)

func _ready():
	var _a = connect("file_selected", self, "_on_select_file")
	_a = connect("hide", self, "_on_select_file", [null])

func prompt_save_file():
	mode = FileDialog.MODE_SAVE_FILE
	show_up()

func prompt_select_file():
	mode = FileDialog.MODE_OPEN_FILE
	show_up()

func show_up():
	popup_centered()
	deselect_items()
	current_file = ""
	invalidate()

var dir = null
var enforce = true
var basic_path = Global.main_path+"/saves"
func _process(_delta):
	if dir == null:
		current_dir = basic_path
		
	if current_dir != dir:
		var begins = current_dir.begins_with(basic_path)
		
		if not begins:
			if enforce:
				current_dir = basic_path
				invalidate()
		dir = current_dir
		

func _on_select_file(path):
	#print("FileDialog:_on_select_file('%s')"%path)
	emit_signal("done_selecting", path)

