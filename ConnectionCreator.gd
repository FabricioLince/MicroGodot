extends Line2D

var creating := false setget set_creating
func set_creating(_v): pass
var connector = null
var corners := []

const Connector = preload("res://connector/Connector.gd")

func _ready():
	set_process(false)

func _process(_delta):
	if points.size() != corners.size() + 2:
		clear_points()
		add_point(connector.global_position)
		for c in corners:
			add_point(c)
		add_point(Vector2.ZERO)
	set_point_position(points.size()-1, Global.put_on_grid(get_global_mouse_position()))

func start(connector_start):
	creating = true
	connector = connector_start
	show()
	clear_points()
	add_point(connector_start.global_position)
	add_point(get_global_mouse_position())
	set_process(true)

func end(connector_end):
	if connector_end:
		#if connector.kind != connector_end.kind:
		var con = Instantiator.connect_directly(connector, connector_end)
		if con:
			if connector.kind == Connector.Kind.INPUT:
				corners.invert()
			for corner in corners:
				con.add_corner(corner)
	
	creating = false
	hide()
	set_process(false)
	corners.clear()


func add_corner(position:Vector2):
	corners.append(Global.put_on_grid(position))
