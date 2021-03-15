extends Node2D

const complex_chip_extension = ".chip"
const script_chip_extension = ".gd"

var standalone setget set_none, is_standalone
func is_standalone(): return OS.has_feature("standalone")

func _ready():
	saves_path = self.saves_path
	scripts_path = self.scripts_path
	#print("saves_path: ", saves_path)
	#print("scripts_path: ", scripts_path)

enum ComplexInputUseKind { CHIP_INPUT, CONSTANT }
enum ComplexOutputUseKind { CHIP_OUTPUT, IGNORE }
var complex_input_use_captions = ["Chip Input", "Constant"]
const complex_output_use_captions = ["Chip Output", "Ignore"]

func complex_input_use_from_string(string):
	return ComplexInputUseKind.keys().bsearch(string)
func complex_output_use_from_string(string):
	return ComplexOutputUseKind.keys().bsearch(string)
	
enum ShowValueKind { PURE_VALUE, TWOS_COMPLEMENT }

func show_value_kind_from_string(string):
	return ShowValueKind.keys().bsearch(string)

func event_pos_to_global_pos(event_pos):
	return get_canvas_transform().affine_inverse().xform(event_pos)


func complex_chip_full_path(path):
	#print("complex_chip_full_path('%s')"%path)
	var full_path = path
	if not full_path.begins_with(saves_path):
		full_path = combine_paths(saves_path, full_path)
	if not full_path.ends_with(complex_chip_extension):
		full_path += complex_chip_extension
	#print("full path = ", full_path)
	return full_path

func complex_chip_local_path(path):
	var local_path = ProjectSettings.localize_path(path)
	#print("complex_chip_local_path('%s')"%path)
	#print("localized path = ", local_path)
	
	var find = local_path.find(saves_path)
	if find >= 0:
		local_path = local_path.substr(find + saves_path.length())
		
	#print("final local path = ", local_path)
	
	return local_path

func script_chip_full_path2(path):
	#print("script_chip_full_path2('%s')"%path)
	var full_path = path
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

var main_path setget set_none, get_main_path
func get_main_path():
	return get_exe_path().substr(2, get_exe_path().length()-12)

var saves_path setget set_none, get_saves_path
func get_saves_path():
	if is_standalone():
		return combine_paths(self.main_path, "saves/")
	return "res://saves/"

var scripts_path setget set_none, get_scripts_path
func get_scripts_path():
	if is_standalone():
		return combine_paths(self.main_path, "chips/")
	return "res://chips/"

func combine_paths(p1, p2):
	var path = p1 + "/" + p2
	return path.replace("//", "/").replace(":/", "://")


func signal_to_color(sig):
	match (sig):
		Signal.Kind.UNDEFINED:
			return Color.yellow
		Signal.Kind.HIGH:
			return Color.green
		Signal.Kind.LOW:
			return Color.gray

func put_on_grid(pos):
	var grid_size = 16
	pos.x = int(pos.x/grid_size)*grid_size
	pos.y = int(pos.y/grid_size)*grid_size
	return pos

func set_none(_a): pass
