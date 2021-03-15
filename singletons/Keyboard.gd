extends Node2D



var keys = {}
var key_listeners = {}

func is_pressed(scancode):
	return keys.has(scancode) and keys[scancode]

func _unhandled_input(event):
	if event is InputEventKey:
		if not event.pressed and keys.get(event.scancode):
			var listeners = key_listeners.get(event.scancode)
			if listeners:
				for l in listeners:
					l.target.call(l.method)
		keys[event.scancode] = event.pressed
		

func add_listener(scancode, target, method):
	if not key_listeners.has(scancode):
		key_listeners[scancode] = []
	key_listeners[scancode].append({
		target = target,
		method = method
	})
func remove_listener(scancode, target, method):
	if key_listeners.has(scancode):
		var to_remove
		for l in key_listeners[scancode]:
			if l.target == target and l.method == method:
				to_remove = l
				break
		if to_remove:
			key_listeners[scancode].erase(to_remove)
