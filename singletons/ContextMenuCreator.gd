extends Node2D

const Group = preload("res://scripts/ObjectGroup.gd")

var canvas_layer
var selector
var Mouse

func show_insert_menu(position:Vector2):
	canvas_layer.show_insert_menu(position)

func show_context_menu_for_selection(position:Vector2):
	if selector.selected_items.empty():
		push_error("Tried to show context menu for empty selection")
	elif selector.selected_items.size() == 1:
		var object = selector.selected_items[0]
		show_context_menu_for(object, position)
	else:
		canvas_layer.show_context_menu(position, get_group_context_menu(position))

func show_context_menu_for(object, position:Vector2):
	canvas_layer.show_context_menu(position, get_object_context_menu(object))

func get_group_context_menu(origin):
	return {
		items = [
			context_item("Duplicate", 0),
			context_item("Delete", 1)
		],
		callback = {target = self, method = "on_group_context_menu", 
		args=[Global.event_pos_to_global_pos(origin)]}
	}

func get_object_context_menu(object):
	if object.get("is_connection") or object.get("is_connection_corner"):
		return {
			items = [context_item("Delete", 1)],
			callback = {target = self, method = "on_object_context_menu", args=[object]},
		}
	if object.get("is_connector"):
		return {}
	return {
		items = [ context_item("Duplicate", 0), context_item("Delete", 1) ],
		callback = {target = self, method = "on_object_context_menu", args=[object]},
	}

func context_item(label_, id_):
	return {
		kind = "item",
		label = label_,
		id = id_
	}

func on_object_context_menu(item_id, object):
	if object.has_method("description"):
		print("Context menu for %s = %s"%[str(object.description()), str(item_id)])
	else:
		print("Context menu for %s = %s"%[str(object), str(item_id)])
	match item_id:
		0:
			var copy = Instantiator.spawn_component_from_info(object.get_info())
			copy.set_position(object.position + Vector2(0, 64))
			Mouse.holding = copy
		1:
			object.on_delete()

func on_group_context_menu(item_id, origin):
	match item_id:
		0:
			duplicate_selection(origin)
		1:
			selector.on_key_delete()

func duplicate_selection(origin):
	var objects = selector.selected_items.duplicate()
	selector.deselect_all()
	var group = Group.new()
	var copies = {}
	for object in objects:
		if not object.get("is_component"): continue
		var copy = Instantiator.copy(object)
		copy.set_position(object.position)
		selector.select(copy)
		group.add_object(copy, origin - object.position)
		var new_objects = check_connections(object, copy, objects, copies)
		for obj in new_objects:
			selector.select(obj)
			group.add_object(obj, origin - obj.position)
		copies[object] = copy
	
	Mouse.holding = group

func check_connections(object, copy, objects, copies):
	var new_objects = []
	for other in objects:
		if other == object: continue
		var other_copy = copies.get(other)
		if other_copy == null: continue
		for con in other.connections:
			if object.connections.has(con):
				var from_copy = copy
				var to_copy = other_copy
				#print(con.description())
				if con.connected_from.component.id == object.id:
					pass#print("%s connected to %s"%[object.description(), other.description()])
				else:
					from_copy = other_copy
					to_copy = copy
					#print("%s connected to %s"%[other.description(), object.description()])
				
				var from_connector = from_copy.connectors.get_out_connector_by_index(con.connected_from.index)
				var to_connector = to_copy.connectors.get_in_connector_by_index(con.connected_to.index)
				#print("Connection between %s and %s"%[from_connector.description(), to_connector.description()])
				#yield(get_tree(), "idle_frame")
				var con_copy = Instantiator.connect_directly(from_connector, to_connector)
				con_copy.corners_from_info(con.get_info())
				for corner in con_copy.corners:
					new_objects.append(corner)
	return new_objects

