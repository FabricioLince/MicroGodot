extends Node2D

signal deleted(connection)

const is_connection = true

const Connector = preload("res://connector/Connector.gd")
var connected_from setget set_from
func set_from(from):
	if connected_from:
		connected_from.listeners.erase(func_ref)
		connected_from.erase_connection(self)
	connected_from = from
	if connected_from:
		connected_from.listeners.append(func_ref)
		connected_from.append_connection(self)
	if connected_to and connected_from:
		pass_signals(connected_from.get_signals())
var connected_to setget set_to
func set_to(to):
	if connected_to:
		connected_to.erase_connection(self)
	connected_to = to
	if connected_to:
		connected_to.append_connection(self)
	if connected_to and connected_from:
		pass_signals(connected_from.get_signals())

onready var func_ref = funcref(self, "pass_signals")
onready var line = $Line2D

var corners = []

func _process(_delta):
	check_for_deletion()

func connect_on(obj):
	if obj:
		if obj.get("is_connector"):
			if obj.kind == Connector.Kind.INPUT:
				self.connected_to = obj
			else:
				self.connected_from = obj
		else:
			connect_on(obj.get("connector"))
	draw_connection_line()

func draw_connection_line():
	if connected_from and connected_to:
		var parent_pos = get_parent().global_position
		var parent_scale = get_parent().scale
		var from_p = (connected_from.global_position/parent_scale)-(parent_pos/parent_scale)
		var to_p = (connected_to.global_position/parent_scale)-(parent_pos/parent_scale)

		line.clear_points()
		line.add_point(from_p)
		for c in corners:
			line.add_point(c.global_position)
		line.add_point(to_p)
		
		var col = $Area2D/CollisionPolygon2D
		var points = line.points
		#print("points are: ", points)
		for i in range(line.points.size()-1):
			#print("appending ", line.points.size()-1-i)
			points.append(line.points[line.points.size()-1-i]+Vector2(2, 2))
		col.polygon = points

func add_corner(position, index = -1):
	var corner = preload("res://connector/ConnectionCorner.tscn").instance()
	$Corners.add_child(corner)
	corner.connection = self
	corner.set_position(position)
	if index == -1: index = corners.size()
	corners.insert(index, corner)
	draw_connection_line()
	recolor(connected_from.get_signals())

func pass_signals(signals):
	#print("signals passed = ", signals)
	yield(get_tree(), "idle_frame")
	if check_for_deletion():
		return
	connected_to.set_input(signals)
	recolor(signals)

func recolor(signals):
	if signals.size() == 1:
		line.default_color = Global.signal_to_color(signals[0])
	else:
		var n = Signal.List.to_number(signals)
		if n < 0:
			line.default_color = Global.signal_to_color(-1)
		elif n == 0:
			line.default_color = Global.signal_to_color(0)
		else:
			line.default_color = Global.signal_to_color(1)
			#var max_n = Signal.Utils.int_pow(2, signals.size())
			#line.default_color = Color.from_hsv(1.0*n/max_n, 1, 0.4)
	line.default_color.v = 0.3
	for c in corners:
		c.set_color(line.default_color)

func force_update():
	yield(get_tree(), "idle_frame")
	check_for_deletion()

func check_for_deletion():
	if not is_valid():
		if connected_to:
			var signals = Signal.List.repeat(Signal.Kind.UNDEFINED, 1)
			connected_to.set_input(signals)
		.queue_free()
		self.connected_from = null
		self.connected_to = null
		return true

func on_delete():
	emit_signal("deleted", self)
	self.connected_from = null
	check_for_deletion()

func queue_free():
	push_warning("You shouldn't call 'queue_free' on a connection (use 'on_delete' instead)")
	on_delete()

func get_info():
	var corner_info = []
	for c in corners:
		corner_info.append(c.position)
	return {
		from = connected_from.component.id,
		from_index = connected_from.index,
		to = connected_to.component.id,
		to_index = connected_to.index,
		corners = corner_info,
	}
func corners_from_info(info):
	if not info.has("corners"): return
	for c in info.corners:
		var pos = c
		if typeof(c)==TYPE_STRING:
			pos = SerializerHelper.string_to_vector2(c)
		add_corner(pos)

func description():
	if not is_valid():
		.queue_free()
		return ""
	return "Connection\n"+\
	"from: " + connected_from.description()+"\n"+\
	"to: " + connected_to.description()

func on_simple_click(info):
	var index = closest_point_to(info.global_position).index
	add_corner(info.global_position, index)
	draw_connection_line()
	if connected_from:
		print("signals = ", connected_from.get_signals())
	print("from = ", connected_from.description())
	print("to = ", connected_to.description())

func is_valid():
	return connected_from!=null and connected_to!=null

func closest_point_to(p):
	if line.points.size() < 2: return
	var closest = {position = null, index = -1}
	for i in line.points.size()-1:
		var projection = closest_point_to_segment(line.points[i], line.points[i+1], p)
		if closest.position == null:
			closest.position = projection
			closest.index = i
		elif projection.distance_squared_to(p) < closest.position.distance_squared_to(p):
			closest.position = projection
			closest.index = i
	return closest

func update_closest():
	if line.points.size() < 2: return
	$Closest.position = closest_point_to(get_global_mouse_position()).position
func closest_point_to_segment(v:Vector2, w:Vector2, p:Vector2): 
	# Return minimum distance between line segment vw and point p
	var l2 = v.distance_squared_to(w) # i.e. |w-v|^2 -  avoid a sqrt
	if l2 == 0.0: return v
	# Consider the line extending the segment, parameterized as v + t (w - v).
	# We find projection of point p onto the line. 
	# It falls where t = [(p-v) . (w-v)] / |w-v|^2
	# We clamp t from [0,1] to handle points outside the segment vw.
	var t = max(0, min(1, (p-v).dot(w-v) / l2))
	# const float t = max(0, min(1, dot(p - v, w - v) / l2));
	var projection = v + t * (w - v) # Projection falls on the segment
	return projection
