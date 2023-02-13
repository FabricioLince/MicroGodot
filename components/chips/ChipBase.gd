extends "res://components/Component.gd"

const is_chip = true
var is_label_locked := true

# interface to receive input signals from input connectors
func set_input(_signals:Array, _index:int, _size:int):
	pass

# interface to send output signals to output conectors
func get_output() -> Array:
	push_error("The component should implement that")
	return []

# function to let connectors know that that output has changed
func send_output():
	for c in connectors.out_connectors:
		c.set_signals(get_output().slice(c.index, c.index+c.size-1))

func get_properties() -> Array:
	return []


func set_size(new_size:Vector2):
	#print("setting size for %s = %s"%[description(), str(new_size)])
	new_size.y = max(new_size.y, $ChipDesign.min_height)
	$ChipDesign.set_size(new_size)
	$Area2D/CollisionShape2D.shape.extents = new_size/2
	set_label_offset(new_size.y/2)
	build_selection_line()
