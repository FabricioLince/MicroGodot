extends Node2D

var keys := {}
var key_listeners := {}

func is_pressed(scancode:int):
	return keys.has(scancode) and keys[scancode]

func _unhandled_input(event):
	if event is InputEventKey:
		
		keys[event.scancode] = event.pressed
		
		var listeners = key_listeners.get(event.scancode)
		if listeners:
			for l in listeners:
				if is_instance_valid(l.target):
					l.target.call(l.method, event.pressed)
		

func add_listener(scancode:int, target:Object, method:String):
	if not key_listeners.has(scancode):
		key_listeners[scancode] = []
	key_listeners[scancode].append({
		target = target,
		method = method
	})
func remove_listener(scancode:int, target:Object, method:String):
	if key_listeners.has(scancode):
		var to_remove
		for l in key_listeners[scancode]:
			if l.target == target and l.method == method:
				to_remove = l
				break
		if to_remove:
			key_listeners[scancode].erase(to_remove)
