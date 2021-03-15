extends Control

var insert_popup
var Mouse 
var Board
onready var text_panel = $TextPanel

var steps 
var step_index = 0

func _ready():
	yield(get_tree().create_timer(0.1), "timeout")
	enable_only(get_parent().file_menu.get_popup(), [])
	enable_only(get_parent().insert_menu.get_popup(), [])
	steps = [
		{
			text = "Let's put a Button on the workspace!\n"+\
				"Click with the right mouse button\n"+\
				"anywhere to open the insert menu.",
			get_position = Function.new(self, "follow_mouse", [Vector2(16, 16)]),
			next_step_trigger = Function.new(self, "insert_menu_showing"),
		},
		{
			text = "Select 'Input' -> 'Button'",
			get_position = Function.new(self, "follow_mouse", [Vector2(20, 20)]),
			prepare = Function.new(self, "enable_only", [insert_popup, ["Input", "Button"]]),
			triggers = [
				{
					function = Function.new(self, "built_component", ["Button"]),
					to_step = 2
				}
			]
		},
		{
			text = "Now click to position the Button",
			get_position = Function.new(self, "follow_mouse", [Vector2(10, 10)]),
			next_step_trigger = Function.new(self, "mouse_not_holding"),
		},
		{
			text = "Well done, now a LED\nOpen the insert menu once more.",
			prepare = Function.new(self, "enable_only", [insert_popup, ["Output", "Led"]]),
			get_position = Function.new(self, "follow_mouse", [Vector2(10, 10)]),
			next_step_trigger = Function.new(self, "insert_menu_showing"),
		}
	]

var prep_step = false

func _process(_delta):
	yield(get_tree().create_timer(0.1), "timeout")
	text_panel.show()
	if step_index >= steps.size():
		text_panel.hide()
		set_process(false)
		return
	
	var step = steps[step_index]
	text_panel.text = step.text
	if not prep_step:
		prep_step = true
		if step.has("prepare"):
			step.prepare.call()
		
	text_panel.set_position(step.get_position.call(), false)
	if step.has("next_step_trigger"):
		if step.next_step_trigger.call():
			step_index += 1
			print(step_index, "/", steps.size())
			prep_step = false
	if step.has("triggers"):
		for trigger in step.triggers:
			if trigger.function.call():
				step_index = trigger.to_step
				print(step_index, "/", steps.size())
				prep_step = false
	
func enable_all(menu:PopupMenu):
	for i in menu.get_item_count():
		var text = menu.get_item_text(i)
		menu.set_item_disabled(i, false)
		var submenu = menu.get_item_submenu(i)
		if submenu:
			for c in menu.get_children():
				if c.name == menu.get_item_submenu(i):
					enable_all(c)
func enable_only(menu:PopupMenu, to_enable:Array):
	for i in menu.get_item_count():
		var text = menu.get_item_text(i)
		if to_enable.has(text):
			menu.set_item_disabled(i, false)
			var submenu = menu.get_item_submenu(i)
			if submenu:
				for c in menu.get_children():
					if c.name == menu.get_item_submenu(i):
						enable_only(c, to_enable)
		else:
			menu.set_item_disabled(i, true)

func mouse_not_holding():
	return Mouse.holding == null
func follow_mouse(offset=Vector2.ZERO):
	return get_global_mouse_position()+offset
func insert_menu_showing():
	return insert_popup.visible
func built_component(component_name):
	for c in Board.components:
		if c.component_name() == component_name:
			return true
	return false

class Function:
	var _target : Object
	var _method : String
	var _args : Array
	func _init(target, method, args=[]):
		_target = target
		_method = method
		_args = args
	func call(args = null):
		if args:
			return _target.callv(_method, args)
		return _target.callv(_method, _args)
