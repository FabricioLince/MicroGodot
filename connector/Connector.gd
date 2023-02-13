extends Node

onready var sprite : Sprite = $Sprite
onready var label_node : Label = $Label
onready var area2d : Area2D = $Area2D
var label : String setget set_label, get_label

var component
var index : int # cumulative index
var size : int

const is_connector = true
enum Kind { INPUT, OUTPUT }

func append_connection(c):
	component.connections.append(c)
func erase_connection(c):
	component.connections.erase(c)

func _ready():
	sprite.modulate = Global.con_size_color(size)

func description():
	return component.label+" ("+str(index)+":"+str(size)+")"


func set_label(l:String):
	label_node.text = l
func get_label() -> String:
	return label_node.text
