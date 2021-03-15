extends AcceptDialog

signal button_pressed(which)

var custom_buttons = []
var captions = []

func prompt(text, options=null, title=null):
	captions.clear()
	dialog_text = text
	if options and options.size()>0:
		get_ok().text = options[0]
		for i in range(options.size()):
			if i == 0: continue
			var b = add_button(options[i], true, str(i))
			custom_buttons.append(b)
			captions.append(options[i])
	else:
		get_ok().text = "OK"
		captions.append("OK")
		
	if title:
		window_title = title
	popup_centered()

func prompt_warning(text, title=null):
	prompt(text, null, title)

func prompt_confirmation(text, title=null):
	prompt(text, ["OK", "Cancel"], title)

func _on_AcceptDialog_confirmed():
	emit_signal("button_pressed", 0)

func _on_AcceptDialog_custom_action(action):
	hide()
	emit_signal("button_pressed", int(action))


func _on_AcceptDialog_popup_hide():
	for b in custom_buttons:
		b.queue_free()
	custom_buttons.clear()
