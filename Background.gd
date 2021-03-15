extends Sprite

onready var camera = get_node("../Camera2D")

var grid_size = 64

func _ready():
	var _a = get_viewport().connect("size_changed", self, "size_changed")
	_a = camera.connect("moved", self, "camera_moved")
	_a = camera.connect("zoom_changed", self, "camera_zoom")
	
	size_changed()
	camera_moved(camera.position)

func size_changed():
	var desired_size = get_viewport_rect().size
	desired_size += Vector2.ONE * grid_size
	desired_size *= camera.zoom
	var s = grid_size*2
	region_rect.size.x = floor(desired_size.x/s)*s + s
	region_rect.size.y = floor(desired_size.y/s)*s + s
	camera_moved(camera.position)

func camera_moved(_camera_pos):
	position = camera.position
	position.x = int(position.x/grid_size)*grid_size
	position.y = int(position.y/grid_size)*grid_size

func camera_zoom(_camera_zoom):
	size_changed()

