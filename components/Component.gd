extends Node2D

signal deleted(component)

# INFO
var id = -1 # must be set by the board
var label setget set_label, get_label

const is_component = true
const is_selectable = true

var connections = []
onready var connectors = $Connectors
onready var label_node = $Label

var lock_to_grid = true
var real_pos

func _ready():
	real_pos = global_position
	if lock_to_grid:
		position = Global.put_on_grid(position)
	$Area2D/CollisionShape2D.shape = $Area2D/CollisionShape2D.shape.duplicate()
	build_selection_line()

func build_selection_line():
	var col_shape = $Area2D/CollisionShape2D.shape as RectangleShape2D
	$SelectionLine.draw_line_for_shape(col_shape)

func set_position(new_pos):
	position = new_pos
	real_pos = new_pos
	if lock_to_grid: position = Global.put_on_grid(position)
	for c in connections:
		if c:
			c.draw_connection_line()

func on_delete():
	emit_signal("deleted", self)
	queue_free()
	for c in connections:
		if c:
			c.force_update()

func description():
	return component_name() + " " + self.label

func component_name():
	return "Component"

# must be overwritten be child classes to provide
# the relevant info to be serialized
func get_info():
	return {
		id = self.id,
		type = component_name(),
		label = self.label,
		position = self.position,
	}
func from_info(info):
	self.id = info.id
	if info.has("label"):
		self.label = info.label
	self.position = info.position
	self.real_pos = info.position

func set_label(l):
	label_node.text = l
func get_label():
	return label_node.text
func set_label_offset(offset):
	label_node.rect_position.y = offset

# child classes must create an Array of properties to show on the Info Panel
func get_properties():
	return [
		{
			kind = "text",
			label = "Name",
			name = "label"
		}
	]

