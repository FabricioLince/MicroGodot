extends "res://components/Component.gd"

const is_bus = true

const Connector = preload("res://connector/Connector.gd")
const InConnector = preload("res://connector/InConnector.tscn")
const OutConnector = preload("res://connector/OutConnector.tscn")

onready var bus = self
onready var bus_end = $BusEnd

var input_connectors := []
var output_connectors := []

var data := []
var _to_do := []
var _corners := []

func _process(_delta):
	if _to_do.size() > 0:
		var connector = _to_do.pop_back()
		for c in connections:
			if c.connected_from == connector:
				connector.global_position = c.corners.front().global_position
				_add_corner(c.corners.front())
			elif c.connected_to == connector:
				connector.global_position = c.corners.back().global_position
				_add_corner(c.corners.back())
	else:
		set_process(false)

func _add_corner(corner:Node2D):
	_corners.append({corner=corner, delta=corner.global_position-global_position})

func set_position(new_pos:Vector2):
	.set_position(new_pos)
	for c in _corners:
		if is_instance_valid(c.corner):
			c.corner.global_position = global_position + c.delta

func set_input(signals:Array, _index:int, size:int):
#	print("setting bus signals ", signals, " on ", index)
	if Signal.List.is_any(signals, Signal.Kind.UNDEFINED):
		return
	data = signals
	for c in output_connectors:
		c.set_signals(data)
	if size == 1:
		modulate = Global.signal_to_color(signals[0])
	else:
		modulate = Global.con_size_color(size)
	modulate.v = 0.8

func get_output() -> Array:
	return data

func create_connector_for(connector):
	match connector.kind:
		Connector.Kind.INPUT:
			var con := add_con(OutConnector, connector.size)
			output_connectors.append(con)
			return con
		Connector.Kind.OUTPUT:
			var in_con := add_con(InConnector, connector.size)
			input_connectors.append(in_con)
			return in_con

func add_con(Scene:PackedScene, size:int) -> Connector:
	var con := Scene.instance()
	con.component = self
	con.index = 0
	con.size = size
	add_child(con)
	con.sprite.hide()
	_to_do.append(con)
	set_process(true)
	con.area2d.queue_free()
	return con as Connector

func rightmost_connector_pos() -> Vector2:
	var pos := Vector2.ZERO
	for con in output_connectors:
		if con.position.x > pos.x:
			pos = con.position
	for con in input_connectors:
		if con.position.x > pos.x:
			pos = con.position
	return pos

func description() -> String: return "Bus"
func component_name() -> String: return "Bus"

func get_info() -> Dictionary:
	var info := .get_info()
	info.erase("label")
	info.bus_end = bus_end.position
	return info

func from_info(info:Dictionary):
	.from_info(info)
	bus_end.position = info.bus_end
	bus_end.update_line()

func get_properties() -> Array:
	return []

class Simulated:
	extends "res://components/chips/ScriptChip/ScriptChipBase.gd"
	var data := []
	const input_spec = {i=16}
	const output_spec = {o=16}
	func on_load():
		data = Signal.List.repeat(Signal.Kind.UNDEFINED, 16)
	func on_set_input():
	#	print("setting bus signals ", signals, " on ", index)
		var signals = get_input_v()
		if Signal.List.is_any(signals, Signal.Kind.UNDEFINED):
			return
		data = signals
		set_output_v(data)
