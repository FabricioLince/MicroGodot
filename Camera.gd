extends Camera2D

signal moved(new_position)
signal zoom_changed(new_zoom)

var board
onready var zoom_label : Label = $"/root/Editor/CanvasLayer/ZoomLabel"

func set_position(p:Vector2):
	position = p
	emit_signal("moved", position)

func move(relative:Vector2):
	set_position(position + relative*self.zoom)

func apply_zoom(zoom:float, focus:Vector2):
	var new_zoom := self.zoom * zoom
	if new_zoom.x > 3: return
	if new_zoom.x < 1.0/3: return
	self.zoom = new_zoom
	move((focus - position) * sign(zoom) * 0.1)
	zoom_label.text = str(stepify(1.0/self.zoom.x, 0.01))+"X"
	emit_signal("zoom_changed", zoom)

func reset_zoom():
	self.zoom = Vector2.ONE
	zoom_label.text = str(self.zoom)
	emit_signal("zoom_changed", zoom)

func center_components(components:Array):
	if components.size() > 0:
		var med := Vector2.ZERO
		for c in board.components:
			med += c.position
		med /= board.components.size()
		set_position(med)
