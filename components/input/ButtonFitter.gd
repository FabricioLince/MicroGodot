extends Node2D

func _ready():
	update_fitting()

func update_fitting():
	var children = get_live_children()
	if children.size() == 0:
		return
	var req_scale = 1.0/children.size()
	var x_delta = 64/(children.size()+1)
	var o_x = -32+x_delta
	for c in children:
		c.scale.x = req_scale
		c.position.x = o_x
		o_x += x_delta
	
func get_live_children():
	var cs = []
	for c in get_children():
		if c.visible:
			cs.append(c)
	return cs
