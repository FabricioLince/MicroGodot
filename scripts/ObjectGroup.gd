extends Object

# warning-ignore:unused_signal
signal update_info_panel() # the signal is send by receiving the signal from the objects

var objects = []
var positions_delta = []

var common_properties = []

func add_object(object, position_delta):
	objects.append(object)
	positions_delta.append(position_delta)
	if object.has_signal("update_info_panel"):
		object.connect("update_info_panel", self, "emit_signal", ["update_info_panel"])

func remove_connections():
	for o in objects:
		if o and o.has_signal("update_info_panel") and o.is_connected("update_info_panel", self, "emit_signal"):
			o.disconnect("update_info_panel", self, "emit_signal")

func set_position(p):
	#print("setting group position to %s (%s)"%[p, click_pos])
	for i in range(objects.size()):
		objects[i].set_position(p - positions_delta[i])

func on_mouse_drop(_pos):
	call_deferred("free")

func get_properties():
	var first_comp = first_component()
	if not first_comp: return []
	common_properties = first_comp.get_properties().duplicate()
	
	for o in objects:
		if not o.get("is_component"): continue
		var o_props = o.get_properties()
		var to_remove = []
		for cp in common_properties:
			if has_property(o_props, cp):
				#print(cp, " is in ", o_props)
				pass
			else:
				to_remove.append(cp)
		for cp in to_remove:
			common_properties.erase(cp)
	#print("COMMON: ", common_properties)
	return common_properties

func get(name):
	for cp in common_properties:
		if cp.get("name") == name:
			return objects[0].get(name)
	return .get(name)
func set(name, value):
	#print("setting %s = %s"%[name, value])
	for cp in common_properties:
		if cp.name == name:
			for o in objects:
				o.set(name, value)
			return 
	.set(name, value)

func has_property(properties, property):
	for p in properties:
		var ok = true
		if property.get("kind") != p.get("kind"):
			ok = false
		if property.get("name") != p.get("name"):
			ok = false
		for key in p:
			if p[key] != property.get(key):
				#ok = false
				break
		if ok: return true
	return false

func description():
	if objects.size() == 0:
		return "empty group"
	var first_comp = first_component()
	if objects.size() == 1:
		if first_comp:
			return first_comp.description()
		return null # ?
	if not first_comp: return null
	var same_component = true
	var same_description = true
	var component_name = first_comp.component_name()
	var component_desc = first_comp.description()
	for o in objects:
		if not o.get("is_component"): continue
		if o.component_name() != component_name:
			same_component = false
		if o.description() != component_desc:
			same_description = false
	if same_description:
		return "%d %s"%[component_amount(), component_desc]
	if same_component:
		return "%d %s"%[component_amount(), component_name]
	return "%d objects"%objects.size()

func on_delete():
	for o in objects:
		o.on_delete()

func component_amount():
	var amount = 0
	for o in objects:
		if o.get("is_component"):
			amount += 1
	return amount
func first_component():
	for o in objects:
		if o.get("is_component"):
			return o

var valid = true setget set_, is_valid
func set_(_a): pass
func is_valid():
	for o in objects:
		if o == null:
			return false
	return true
