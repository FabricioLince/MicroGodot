extends Node2D

signal done_loading()
signal done_clearing()
signal modification()

onready var camera = get_node("../Camera2D")
onready var loading_bar = get_node("/root/Editor/CanvasLayer/LoadingBar")
var components := []
var connections := []

var last_id := 0
func new_id() -> int:
	last_id = last_id+1
	return last_id-1

func clear_all():
	for c in get_children():
		if not c.get("is_component"):
			c.connected_to = null # to block invalid signals passing through
			c.on_delete()
	
	for c in get_children():
		if c.get("is_component"):
			c.on_delete()
	yield(get_tree(), "idle_frame")
	emit_signal("done_clearing")

func get_by_id(id):
	for c in get_children():
		if c.get("id") == id:
			return c

func add_child(c:Node, legible_unique_name:=false):
	c.connect("deleted", self, "on_object_deleted", [c])
	.add_child(c, legible_unique_name)
	if c.get("id") != null:
		c.id = new_id()
	if c.get("is_component"):
		components.append(c)
	c.set("instantiator", Instantiator)
	c.set("board", self)
	if c.has_signal("modified"):
		c.connect("modified", self, "emit_signal", ["modification"])
	emit_signal("modification")

func on_object_deleted(obj):
	components.erase(obj)
	emit_signal("modification")

func normalize_ids():
	last_id = 0
	for c in components:
		c.id = new_id()

func serialize_content() -> String:
	var ios := []
	var chips := []
	var cons := []
	var extras := []
	
	normalize_ids()
	
	for c in get_children():
		var info = c.get_info()
		if c.get("is_io"):
			ios.append(info)
		elif c.get("is_chip"):
			chips.append(info)
		elif c.get("is_connection"):
			cons.append(info)
		else:
			extras.append(info)
	
	var all := {
		io = ios,
		chips = chips,
		extras = extras,
		connections = cons,
	}
	var content := JSON.print(all, "\t")
	#content = content.replace("{", "\n{")
	#content = content.replace("],", "],\n")
	return content

func read_serialized_content(content:String):
	var all = JSON.parse(content)
	if all:
		all = all.result
		if typeof(all) != TYPE_DICTIONARY:
			print("Couldn't parse content:")
			print(content)
			return
		
		loading_bar.total = float(all.io.size() + all.chips.size() + all.connections.size() + all.get("extras", []).size())
		for list in [all.io, all.chips, all.get("extras", [])]:
			for info in list:
				_deserialize_component(info)
				yield(get_tree(), "idle_frame")
				camera.center_components(components)
				loading_bar.increment()
			
		yield(get_tree(), "idle_frame")
		for info in all.connections:
			#print(info)
			var from_comp = get_by_id(info.from)
			if not is_instance_valid(from_comp):
				continue
			var from_connector = from_comp.connectors.get_out_connector_by_index(info.from_index)
			var to_comp = get_by_id(info.to)
			if not is_instance_valid(to_comp):
				continue
			var to_connector = to_comp.connectors.get_in_connector_by_index(info.to_index)
			if from_connector.get("is_bus"):
				# -- invert order because bus can't initiate connection
				var to_bus = from_connector
				from_connector = to_connector
				from_comp = to_comp
				to_comp = to_bus
				to_connector = to_bus
			var con = Instantiator.connect_directly(from_connector, to_connector)
			if con:
				con.corners_from_info(info)
				connections.append(con)
				con.connect("deleted", self, "_erase_con")
				yield(get_tree(), "idle_frame")
			loading_bar.increment()
	
	emit_signal("done_loading")

func _deserialize_component(info:Dictionary):
	SerializerHelper.renormalize(info)
	var c = Instantiator.spawn_component_from_info(info)
	if is_instance_valid(c):
		last_id = int(max(c.id, last_id))
	return c

func _erase_con(con):
	connections.erase(con)
