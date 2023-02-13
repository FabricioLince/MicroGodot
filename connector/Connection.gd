extends Node2D

signal deleted()

const is_connection = true

const Connector = preload("res://connector/Connector.gd")

onready var func_ref := funcref(self, "pass_signals")
onready var line : Line2D = $Line2D
onready var col : CollisionPolygon2D = $Area2D/CollisionPolygon2D
onready var corners_list : Node2D = $Corners

var corners := []
var connected_from setget set_from
var connected_to setget set_to

var gradient : Gradient

func _ready():
	gradient = line.gradient.duplicate()
	line.gradient = gradient

func set_from(from):
	if is_instance_valid(connected_from):
		connected_from.listeners.erase(func_ref)
		connected_from.erase_connection(self)
	connected_from = from
	if is_instance_valid(connected_from):
		connected_from.listeners.append(func_ref)
		connected_from.append_connection(self)
	if is_instance_valid(connected_to) and is_instance_valid(connected_from):
		pass_signals(connected_from.get_signals(), true)


func set_to(to):
	if is_instance_valid(connected_to):
		connected_to.erase_connection(self)
	connected_to = to
	if is_instance_valid(connected_to):
		connected_to.append_connection(self)
	if is_instance_valid(connected_to) and is_instance_valid(connected_from):
		pass_signals(connected_from.get_signals(), true)


func _process(_delta):
	check_for_deletion()


func connect_on(obj:Node):
	if is_instance_valid(obj):
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
		
		var index := 0
		for _i in range(line.get_point_count() - 1):
			var mid = lerp(line.get_point_position(index), line.get_point_position(index+1), 0.3)
			var mid2 = lerp(line.get_point_position(index), line.get_point_position(index+1), 0.6)
			line.add_point(mid, index+1)
			line.add_point(mid2, index+2)
			index += 3
		
		var points := line.points
		#print("points are: ", points)
		for i in range(line.points.size()-1):
			#print("appending ", line.points.size()-1-i)
			points.append(line.points[line.points.size()-1-i]+Vector2(2, 2))
		col.polygon = points


func add_corner(position:Vector2, index := -1):
	var corner := preload("res://connector/ConnectionCorner.tscn").instance()
	corners_list.add_child(corner)
	corner.connection = self
	corner.set_position(position)
	if index == -1: index = corners.size()
	corners.insert(index, corner)
	draw_connection_line()
	recolor(connected_from.get_signals())


var prev_signals : Array
var frame := 0
var force_next_amount := 0
func pass_signals(signals:Array, force:=false):
	#print("signals passed = ", signals)
	if force_next_amount <= 0 and not force and signals == prev_signals:
		return
	force_next_amount -= 1
	prev_signals = signals
	
	if get_tree().get_frame() == frame:
		Global.repeated -= 1
		if Global.repeated < 0:
			Global.repeated = 100
			#yield(get_tree(), "idle_frame")
			_get_again()
			return
	
	frame = get_tree().get_frame()
	if check_for_deletion():
		return
	connected_to.set_input(signals)
	recolor(signals)
	
	var tween := create_tween()
	tween.tween_method(self, "move_offset", 0.0, 1.0, 0.15)

func _get_again():
	yield(get_tree(), "idle_frame")
	pass_signals(connected_from.get_signals(), true)

func move_offset(v:float):
	gradient.set_offset(1, v-0.1)
	gradient.set_offset(2, v)

func force_next(amount:=1):
	force_next_amount = amount+1
#	var decoy := []
#	for s in connected_from.get_signals():
#		if s == 0:
#			decoy.append(-1)
#		else:
#			decoy.append(0)
#	pass_signals(decoy, true)

func recolor(signals:Array):
	if signals.size() == 1:
		line.default_color = Global.signal_to_color(signals[0])
	else:
		var any := 0
		for s in signals:
			if s != 0:
				any = s
				break
		if any == -1:
			line.default_color = Global.signal_to_color(-1)
		elif any == 1:
			line.default_color = Global.con_size_color(signals.size())
		else:
			line.default_color = Global.signal_to_color(0)
	
	gradient.set_color(2, line.default_color)
	line.default_color.v = 0.5
#	for c in corners:
#		c.set_color(line.default_color)
	gradient.set_color(0, line.default_color)
	gradient.set_color(1, line.default_color)
	gradient.set_color(3, line.default_color)
	#print(gradient.colors)

func force_update():
	yield(get_tree(), "idle_frame")
	check_for_deletion()

func check_for_deletion():
	if not is_valid():
		if is_instance_valid(connected_to):
			var signals := Signal.List.repeat(Signal.Kind.UNDEFINED, 1)
			connected_to.set_input(signals)
		.queue_free()
		self.connected_from = null
		self.connected_to = null
		emit_signal("deleted")
		return true

func on_delete():
	self.connected_from = null
	check_for_deletion()

func queue_free():
	push_warning("You shouldn't call 'queue_free' on a connection (use 'on_delete' instead)")
	on_delete()

func get_info() -> Dictionary:
	var corner_info := []
	for c in corners:
		corner_info.append(c.position)
	return {
		from = connected_from.component.id,
		from_index = connected_from.index,
		to = connected_to.component.id,
		to_index = connected_to.index,
		corners = corner_info,
	}
func corners_from_info(info:Dictionary):
	if not info.has("corners"): return
	for c in info.corners:
		var pos = c
		if typeof(c)==TYPE_STRING:
			pos = SerializerHelper.string_to_vector2(c)
		add_corner(pos)

func description() -> String:
	if not is_valid():
		.queue_free()
		return ""
	return "Connection\n"+\
	"from: " + connected_from.description()+"\n"+\
	"to: " + connected_to.description()

func on_simple_click(info):
	if (info.event.button_index != BUTTON_LEFT):
		return
	var index = closest_point_to(info.global_position).index
	# -- divid index by 3 because there's 2 extra points per corner in the line
	add_corner(info.global_position, index/3) 
	draw_connection_line()
#	if is_instance_valid(connected_from):
#		var value = Signal.List.to_number(connected_from.get_signals())
#		var bits = connected_from.get_signals().size()
#		print("signals = ", connected_from.get_signals(), " ", ("%0"+str(bits/4)+"X")%(value))
#	print("from = ", connected_from.description())
#	print("to = ", connected_to.description())

func is_valid():
	return is_instance_valid(connected_from) and is_instance_valid(connected_to)

func closest_point_to(p:Vector2):
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
func closest_point_to_segment(v:Vector2, w:Vector2, p:Vector2) -> Vector2: 
	# Return minimum distance between line segment vw and point p
	var l2 := v.distance_squared_to(w) # i.e. |w-v|^2 -  avoid a sqrt
	if l2 == 0.0: return v
	# Consider the line extending the segment, parameterized as v + t (w - v).
	# We find projection of point p onto the line. 
	# It falls where t = [(p-v) . (w-v)] / |w-v|^2
	# We clamp t from [0,1] to handle points outside the segment vw.
	var t := max(0, min(1, (p-v).dot(w-v) / l2))
	# const float t = max(0, min(1, dot(p - v, w - v) / l2));
	var projection := v + t * (w - v) # Projection falls on the segment
	return projection
