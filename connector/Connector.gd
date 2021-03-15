extends Node

var component
var index # cumulative index
var size

const is_connector = true
enum Kind { INPUT, OUTPUT }

func append_connection(c):
	component.connections.append(c)
func erase_connection(c):
	component.connections.erase(c)

func _ready():
	if size == 1:
		$Sprite.modulate = Color.black
	elif size == 4:
		$Sprite.modulate = Color.purple
	elif size == 8:
		$Sprite.modulate = Color.green
	elif size == 12:
		$Sprite.modulate = Color.magenta
	elif size == 16:
		$Sprite.modulate = Color.cyan

func description():
	var con_label = get_label()
	if con_label:
		pass#return component.label +" : "+con_label
		
	return component.label+" ("+str(index)+":"+str(size)+")"

var label setget set_label, get_label
func set_label(l):
	$Label.text = l
func get_label():
	return $Label.text
