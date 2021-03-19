extends Node2D

signal done_loading
signal done_clearing
signal modification

onready var camera = get_node("../Camera2D")
onready var loading_bar = get_node("/root/Editor/CanvasLayer/LoadingBar")
var components = []

var last_id = 0
func new_id():
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
		if c.get("is_component"):
			if c.id == id:
				return c

func add_child(c, legible_unique_name=false):
	c.connect("deleted", self, "on_object_deleted")
	.add_child(c, legible_unique_name)
	if c.get("id") != null:
		c.id = new_id()
	if c.get("is_component"):
		components.append(c)
	c.set("instantiator", Instantiator)
	emit_signal("modification")

func on_object_deleted(obj):
	components.erase(obj)
	emit_signal("modification")

func normalize_ids():
	last_id = 0
	for c in components:
		c.id = new_id()

func serialize_content():
	var ios = []
	var chips = []
	var connections = []
	
	normalize_ids()
	
	for c in get_children():
		var info = c.get_info()
		if c.get("is_io"):
			ios.append(info)
		elif c.get("is_chip"):
			chips.append(info)
		elif c.get("is_connection"):
			connections.append(info)
	
	var all = {
		io = ios,
		chips = chips,
		connections = connections,
	}
	var content = JSON.print(all, "\t")
	#content = content.replace("{", "\n{")
	#content = content.replace("],", "],\n")
	return content

func read_serialized_content(content):
	var all = JSON.parse(content)
	if all:
		all = all.result
		if typeof(all) != TYPE_DICTIONARY:
			print("Couldn't parse content:")
			print(content)
			return
		
		loading_bar.total = float(all.io.size() + all.chips.size() + all.connections.size())
		for io in all.io:
			#print(io)
			io.position = SerializerHelper.string_to_vector2(io.position)
			var c = Instantiator.spawn_component_from_info(io)
			last_id = max(c.id, last_id)
			yield(get_tree(), "idle_frame")
			camera.center_components(components)
			loading_bar.increment()
		for chip in all.chips:
			#print(chip)
			chip.position = SerializerHelper.string_to_vector2(chip.position)
			var c = Instantiator.spawn_component_from_info(chip)
			last_id = max(c.id, last_id)
			yield(get_tree(), "idle_frame")
			camera.center_components(components)
			loading_bar.increment()
		yield(get_tree(), "idle_frame")
		for info in all.connections:
			#print(info)
			var from_comp = get_by_id(info.from)
			var from_connector = from_comp.connectors.get_out_connector_by_index(info.from_index)
			var to_comp = get_by_id(info.to)
			var to_connector = to_comp.connectors.get_in_connector_by_index(info.to_index)
			var con = Instantiator.connect_directly(from_connector, to_connector)
			if con:
				con.corners_from_info(info)
				yield(get_tree(), "idle_frame")
			loading_bar.increment()
	
	emit_signal("done_loading")

func wait():
	yield(get_tree().create_timer(0.1), "timeout")
