extends Node2D

const is_selectable = true

var connection
var real_pos

func _ready():
	$SelectionLine.draw_line_for_shape($Area2D2/CollisionShape2D.shape)

func set_position(new_pos):
	position = new_pos
	real_pos = new_pos
	position = Global.put_on_grid(position)
	connection.draw_connection_line()

func on_delete():
	connection.corners.erase(self)
	connection.draw_connection_line()
	queue_free()


func set_color(c):
	$Sprite.modulate = c
