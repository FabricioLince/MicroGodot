extends Node2D

const is_selectable := true
const is_bus := true

onready var bus = get_parent()


onready var selection_line : Line2D = $SelectionLine
onready var area : Area2D = $Area2D
#onready var line : Line2D = $Line2D
var col_shape : RectangleShape2D 

func _ready():
	$Area2D/CollisionShape2D.shape = $Area2D/CollisionShape2D.shape.duplicate()
	col_shape = $Area2D/CollisionShape2D.shape

func update_line():
	col_shape.extents.x = position.x/2
	area.position.x = - position.x/2 + 32
	for line in [$Line2D, $Line2D2, $Line2D3, $Line2D3, $Line2D4, $Line2D5]:
		var y = line.get_point_position(1).y
		line.set_point_position(1, Vector2(-position.x+28, y))

func set_position(new_pos:Vector2):
	var p := Global.put_on_grid(new_pos)
	p.y = bus.global_position.y
	p.x = max(bus.global_position.x+max(90, bus.rightmost_connector_pos().x), p.x)
	global_position = p
	update_line()
