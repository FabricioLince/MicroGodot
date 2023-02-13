extends Node2D

const is_selectable = true
const is_connection_corner = true

var connection
var real_pos : Vector2

func _ready():
	$SelectionLine.draw_line_for_shape($Area2D2/CollisionShape2D.shape)

func set_position(new_pos:Vector2):
	real_pos = new_pos
	position = Global.put_on_grid(new_pos)
	connection.draw_connection_line()

func on_delete():
	connection.corners.erase(self)
	connection.draw_connection_line()
	queue_free()


func set_color(c:Color):
	$Sprite.modulate = c
