extends Node2D

var board
var camera
var selector
var canvas_layer

onready var cursor = $CursorArea
onready var connection_creator = $ConnectionCreator
var click_infos := []

var down_on := {}

var holding = null

func _process(_delta):
	cursor.position = get_global_mouse_position()
	if is_instance_valid(holding):
		holding.set_position(get_global_mouse_position())
	if click_infos.size() > 0:
		# only process the last click info (higher priority)
		var info = click_infos.back()
		process_click_info(info)
		click_infos.clear()

func process_click_info(info):
#	print("Click on ", info.object, " at ", info.event.as_text(), "(%d)"%[info.frame])
	if info.event.pressed:
		# button down event: store info for later use
		down_on[info.event.button_index] = info
		# initialize selector
		selector.start_selecting(info.global_position)
	elif down_on.has(info.event.button_index):
		# button up event:
		var down = down_on[info.event.button_index]
		down_on.erase(info.event.button_index)
#		var a = down.object; if a: a = a.name
#		var b = info.object; if b: b = b.name
		#print(a, " == ", b)
		var delta = down.event.position - info.event.position
		if down.object == info.object:
			# mouse down & mouse up on the same object (can be empty space)
			if delta.length() < 4:
				process_simple_click(info)
		
		if selector.is_selecting():
			selector.done_selecting()
			var items = yield(selector, "selected_items")
			print("Selected %d items"%items.size())
		

func process_simple_click(info):
	if is_instance_valid(holding):
		selector.select_only(holding)
		if holding.has_method("on_mouse_drop"):
			holding.on_mouse_drop(get_global_mouse_position())
		holding = null
		return
	if connection_creator.creating:
		match info.event.button_index:
			BUTTON_LEFT:
				if info.object and info.object.get("is_connector"):
					connection_creator.end(info.object)
				elif info.object and info.object.get("is_bus"):
					connection_creator.add_corner(info.global_position)
					connection_creator.end(info.object.bus)
				else:
					connection_creator.add_corner(info.global_position)
			BUTTON_RIGHT:
				connection_creator.end(null)
		return
	if info.object == null:
		click_on_empty_space(info)
	else:
		click_on_object(info)

func click_on_empty_space(info):
	# has clicked on empty space
	selector.deselect_all()
	match info.event.button_index:
		BUTTON_LEFT:
			pass
		BUTTON_RIGHT:
			ContextMenuCreator.show_insert_menu(info.event.position)

func click_on_object(info):
	# has clicked on object / component
	if info.object.has_method("on_simple_click"):
		info.object.on_simple_click(info)
	else:
		pass
		#print(info.object.name, " doesn't have 'on_simple_click' callback")
	
	match info.event.button_index:
		BUTTON_LEFT:
			if info.object.get("is_connector"):
				connection_creator.start(info.object)
			
			elif info.object.get("is_part_of"):
				info.object = info.object.is_part_of
			
			elif Keyboard.is_pressed(KEY_SHIFT):
				if selector.is_selected(info.object):
					selector.deselect(info.object)
				else:
					selector.select(info.object)
			else:
				selector.select_only(info.object)
			
		BUTTON_RIGHT:
			if selector.is_selectable(info.object):
				if not selector.is_selected(info.object):
					selector.select_only(info.object)
				ContextMenuCreator.show_context_menu_for_selection(info.event.position)
			else:
				ContextMenuCreator.show_context_menu_for(info.object, info.event.position)

# drag = moving the mouse with a button down
func process_drag(motion_event):
	var object = down_on[motion_event.button_mask].object
	if object and object.get("is_selectable"):
		if selector.selected_items.size() == 0:
			# nothing is selected; select object under cursor
			selector.select(object)
		elif not selector.selected_items.has(object):
			# something else is selected
			selector.deselect_all()
			selector.select(object)
		selector.object_group.set_position(Global.event_pos_to_global_pos(motion_event.position))
	else:
		selector.b = get_global_mouse_position()

func delete_on(info):
	if info.object.has_method("on_delete"):
		info.object.on_delete()

func _unhandled_input(event):
	if event is InputEventMouseButton:
		var zoom_factor = 1.1
		if Keyboard.is_pressed(KEY_SHIFT):
			zoom_factor = 1.02
		if event.button_index == BUTTON_WHEEL_DOWN:
			camera.apply_zoom(zoom_factor, Global.event_pos_to_global_pos(event.position))
		elif event.button_index == BUTTON_WHEEL_UP:
			camera.apply_zoom(1.0/zoom_factor, Global.event_pos_to_global_pos(event.position))
		else:
			calc_click(event)
	elif event is InputEventMouseMotion:
		calc_motion(event)

func calc_motion(event):
	if event.button_mask == 0:
		# motion with no button pressed
		return
	if down_on.has(event.button_mask):
		# motion with button pressed
		process_drag(event)
	elif event.button_mask == BUTTON_MASK_MIDDLE:
		camera.move(-event.relative)

func calc_click(event):
	
#	yield(get_tree(), "physics_frame")
#	yield(get_tree(), "physics_frame")
	append_click(event, null)
	for a in cursor.get_overlapping_areas():
		append_click(event, a.get_parent())

func append_click(event, object):
	if click_infos.size() > 0:
		if object == null:
			# there's already a click; don't append an empty space click
			return
		if click_infos.back().object:
			if click_infos.back().object.z_index > object.z_index:
				# there's already a higher priority click
				return
	click_infos.append({
		event = event,
		object = object,
		global_position = Global.event_pos_to_global_pos(event.position)
		#frame = get_tree().get_frame()
		})
