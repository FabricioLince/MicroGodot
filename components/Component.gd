extends Node2D

signal modified()
signal deleted()

# INFO
var id : int = -1 # must be set by the board
var label : String setget set_label, get_label

const is_component = true
const is_selectable = true

var connections := []
onready var connectors = get_node_or_null("Connectors")
onready var label_node : Label = get_node_or_null("Label")
onready var area : Area2D = $Area2D

var lock_to_grid := true
var real_pos : Vector2

func _ready():
	real_pos = global_position
	if lock_to_grid:
		position = Global.put_on_grid(position)
	if get_node_or_null("Area2D/CollisionShape2D"):
		$Area2D/CollisionShape2D.shape = $Area2D/CollisionShape2D.shape.duplicate()
		build_selection_line()

func build_selection_line():
	var col_shape := $Area2D/CollisionShape2D.shape as RectangleShape2D
	$SelectionLine.draw_line_for_shape(col_shape)
	$SelectionLine.position = area.position

func set_position(new_pos:Vector2):
	position = new_pos
	real_pos = new_pos
	if lock_to_grid: position = Global.put_on_grid(position)
	for c in connections:
		if is_instance_valid(c):
			c.draw_connection_line()
	emit_signal("modified")

func on_delete():
	emit_signal("deleted")
	for c in connections:
		if is_instance_valid(c):
			c.force_update()
	queue_free()

func description() -> String:
	return component_name() + " " + self.label

func component_name() -> String:
	return "Component"

# must be overwritten be child classes to provide
# the relevant info to be serialized
func get_info() -> Dictionary:
	return {
		id = self.id,
		type = component_name(),
		label = self.label,
		position = self.position,
	}
func from_info(info:Dictionary):
	self.id = info.id
	if info.has("label"):
		self.label = info.label
	self.position = info.position
	self.real_pos = info.position

func set_label(l:String):
	if is_instance_valid(label_node):
		label_node.text = l
	label = l
func get_label() -> String:
	if is_instance_valid(label_node):
		return label_node.text
	return label
func set_label_offset(offset:float):
	label_node.rect_position.y = offset

# child classes must create an Array of properties to show on the Info Panel
func get_properties() -> Array:
	return [
		{
			kind = "text", # -- kind of input to show in the info panel
			label = "Name", # -- name to be shown with the input on the info panel
			name = "label" # -- name of the property of this class to be associated
		}
	]

var shape_extents : Vector2 setget set_shape_extents, get_shape_extents
func set_shape_extents(extents:Vector2):
	$Area2D/CollisionShape2D.shape.extents = extents
func get_shape_extents() -> Vector2:
	var col : CollisionShape2D = $Area2D/CollisionShape2D
	if col:
		return $Area2D/CollisionShape2D.shape.extents
	return Vector2.ZERO
func set_shape_width(w:int):
	$Area2D/CollisionShape2D.shape.extents.x = w
