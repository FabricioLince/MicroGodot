extends MenuButton

onready var canvas_layer = get_node("/root/Editor/CanvasLayer")


func _ready():
	for _i in range(3):
		yield(get_tree(), "idle_frame")
	canvas_layer.prepare_popup(get_popup(), canvas_layer.insert_menu_items)

