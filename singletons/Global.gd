extends Node2D

var repeated := 100

const complex_chip_extension = ".chip"
const script_chip_extension = ".gd"

var standalone : bool setget set_none, is_standalone
func is_standalone() -> bool: return OS.has_feature("standalone")

var builtin_chips := {
	Logic = preload("res://chips/Logic.gd"),
	Clock = preload("res://chips/Clock.gd"),
	Conversor = preload("res://chips/Conversor.gd"),
	Splitter = preload("res://chips/Splitter.gd"),
	Inverter = preload("res://chips/Inverter.gd"),
	Counter = preload("res://chips/Counter.gd"),
}

func _ready():
	saves_path = self.saves_path
	scripts_path = self.scripts_path
	#print("saves_path: ", saves_path)
	#print("scripts_path: ", scripts_path)

enum ComplexInputUseKind { CHIP_INPUT, CONSTANT }
enum ComplexOutputUseKind { CHIP_OUTPUT, IGNORE }
const complex_input_use_captions = ["Chip Input", "Constant"]
const complex_output_use_captions = ["Chip Output", "Ignore"]

func complex_input_use_from_string(string):
	return ComplexInputUseKind.keys().bsearch(string)
func complex_output_use_from_string(string):
	return ComplexOutputUseKind.keys().bsearch(string)
	
enum ShowValueKind { PURE_VALUE, TWOS_COMPLEMENT }

func show_value_kind_from_string(string):
	return ShowValueKind.keys().bsearch(string)

func event_pos_to_global_pos(event_pos:Vector2) -> Vector2:
	return get_canvas_transform().affine_inverse().xform(event_pos)


func complex_chip_full_path(path:String) -> String:
	#print("complex_chip_full_path('%s')"%path)
	var full_path = path
	if not full_path.begins_with(saves_path):
		full_path = combine_paths(saves_path, full_path)
	if not full_path.ends_with(complex_chip_extension):
		full_path += complex_chip_extension
	#print("full path = ", full_path)
	return full_path

func complex_chip_local_path(path:String) -> String:
	var local_path = ProjectSettings.localize_path(path)
	#print("complex_chip_local_path('%s')"%path)
	#print("localized path = ", local_path)
	
	var find = local_path.find(saves_path)
	if find >= 0:
		local_path = local_path.substr(find + saves_path.length())
		
	#print("final local path = ", local_path)
	
	return local_path

func script_chip_full_path2(path:String) -> String:
	#print("script_chip_full_path2('%s')"%path)
	var full_path := path
	if not full_path.begins_with(scripts_path):
		full_path = combine_paths(scripts_path, full_path)
	if not full_path.ends_with(script_chip_extension):
		full_path += script_chip_extension
	#print("full path = ", full_path)
	return ProjectSettings.globalize_path(full_path)

func script_chip_local_path2(path):
	if not path.begins_with(scripts_path):
		path = combine_paths(scripts_path, path)
	return ProjectSettings.localize_path(path)

var exe_path setget set_none, get_exe_path
func get_exe_path(): return OS.get_executable_path().replace("\\", "/")

var main_path : String setget set_none, get_main_path
func get_main_path() -> String:
	return get_exe_path().substr(2, get_exe_path().length()-12)

var saves_path : String setget set_none, get_saves_path
func get_saves_path() -> String:
	if is_standalone():
		return combine_paths(self.main_path, "saves/")
	return "res://saves/"

var scripts_path : String setget set_none, get_scripts_path
func get_scripts_path() -> String:
	if is_standalone():
		return combine_paths(self.main_path, "chips/")
	return "res://chips/"

func combine_paths(p1:String, p2:String) -> String:
	var path := p1 + "/" + p2
	return path.replace("//", "/").replace(":/", "://")

func signal_to_color(sig:int) -> Color:
	match (sig):
		Signal.Kind.UNDEFINED:
			return Color.yellow
		Signal.Kind.HIGH:
			return Color.crimson
		Signal.Kind.LOW:
			return Color.gray
	return Color.black

func con_size_color(size:int) -> Color:
	if size == 1:
		return Color.black
	elif size == 4:
		return Color.purple
	elif size == 8:
		return Color.green
	elif size == 12:
		return Color.magenta
	elif size == 16:
		return Color.cyan
	return Color.gray

func put_on_grid(pos:Vector2) -> Vector2:
	var grid_size := 16.0
	pos.x = round(pos.x/grid_size)*grid_size
	pos.y = round(pos.y/grid_size)*grid_size
	return pos

func set_none(_a): pass
