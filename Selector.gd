extends Node2D

signal selected_items(items)

const Group = preload("res://scripts/ObjectGroup.gd")

var info_panel

onready var line = $Line2D

onready var shape = $Area2D/CollisionShape2D.shape

var selected_items = []
var object_group

var a = Vector2.ZERO setget set_a
func set_a(na):
	a = na
	update_selector()
var b = Vector2.ZERO setget set_b
func set_b(nb):
	b = nb
	update_selector()

func _ready():
	line.clear_points()
	for _i in range(5):
		line.add_point(Vector2.ZERO)
	Keyboard.add_listener(KEY_DELETE, self, "on_key_delete")

func update_selector():
	line.set_point_position(0, a)
	line.set_point_position(1, Vector2(a.x, b.y))
	line.set_point_position(2, b)
	line.set_point_position(3, Vector2(b.x, a.y))
	line.set_point_position(4, a)
	
	$Area2D.global_position = (a+b)/2.0
	shape.extents = Vector2(abs(a.x-b.x)/2.0, abs(a.y-b.y)/2.0)
	
	var pol = $Polygon2D
	for i in range(4):
		pol.polygon[i] = line.get_point_position(i)

func done_selecting():
	deselect_all()
	
	yield(get_tree(), "physics_frame")
	yield(get_tree(), "physics_frame")
	
	for area in $Area2D.get_overlapping_areas():
		var object = area.get_parent()
		if is_selectable(object):
			select(object)
			#print(comp.description())
	self.a = Vector2.ZERO
	self.b = Vector2.ZERO
	emit_signal("selected_items", selected_items)

func deselect_all():
	while selected_items.size() > 0:
		if selected_items[0]:
			deselect(selected_items[0])
		else: 
			selected_items.remove(0)

func select(item):
	if not is_selectable(item): return
	if is_selected(item): return
	selected_items.append(item)
	item.get_node("SelectionLine").show()
	update_info_for_selection()
	#print("selected items: ", selected_items)

func deselect(item):
	#if selected_items.has(item):
	item.get_node("SelectionLine").hide()
	selected_items.erase(item)
	update_info_for_selection()
	#print("selected items: ", selected_items)

func select_only(item):
	if is_selectable(item):
		deselect_all()
		select(item)

func is_selected(item):
	return selected_items.has(item)
func is_selectable(item):
	return item.get("is_selectable")
func start_selecting(initial_pos):
	self.a = initial_pos
	self.b = initial_pos
func is_selecting():
	return a.distance_squared_to(b) > 4

func on_key_delete():
	if selected_items.size() > 0:
		var descr = null
		if selected_items[0].has_method("description"):
			descr = selected_items[0].description()
		var dialog_text = "Delete?"
		if selected_items.size() > 1:
			dialog_text = "Delete %d items?"%[selected_items.size()]
		else:
			if descr:
				dialog_text = "Delete %s?"%[descr]
		MessageSystem.popup.prompt_confirmation(dialog_text)
		var answer = yield(MessageSystem.popup, "button_pressed")
		if answer == 0:
			for s in selected_items:
				s.on_delete()
			deselect_all()

func update_info_for_selection():
	if selected_items.size() == 0:
		info_panel.hide_info()
	else:
		object_group = Group.new()
		var center = Vector2.ZERO
		for o in selected_items:
			center += o.position
			#print(o, " -> ", o.position)
		center /= selected_items.size()
		#print("center: ", center)
		for o in selected_items:
			object_group.objects.append(o)
			object_group.positions_delta.append(center - o.position)
			#print(o, " -> ", (center - o.position))
		if selected_items.size() == 1:
			info_panel.show_info_for(selected_items[0])
		else:
			info_panel.show_info_for(object_group)
