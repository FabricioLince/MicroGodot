extends Panel

onready var label = $Label

var centered = true

var text setget set_text
func set_text(new_text):
	label.text = ""
	label.rect_size = Vector2(8, 8)
	text = new_text
	label.text = new_text
	label.rect_position = Vector2(8, 8)
	
	yield(get_tree(), "idle_frame")
	self.rect_size = label.rect_size + Vector2(16, 16)

func set_position(new_pos, centered_=null):
	if centered_ != null:
		centered = centered_
	rect_position = new_pos 
	if centered:
		rect_position -= rect_size/2

func center_on_screen():
	var viewport_size = get_viewport_rect().size
	set_position(viewport_size/2)
