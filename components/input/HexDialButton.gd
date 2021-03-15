extends Node2D

onready var hex_input = get_parent().get_parent().get_parent()
export (int) var step = 1

func on_simple_click(_info):
	var v = hex_input.value + step
	#while v < 0: v += hex_input.max_value
	hex_input.value = v

onready var is_part_of = get_parent().get_parent().get_parent()
