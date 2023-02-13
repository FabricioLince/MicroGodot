extends Object
class_name SerializerHelper 

static func string_to_vector2(string:String):
	var regex := RegEx.new()
	regex.compile("(?<x>(?:\\-)?\\d+(?:\\.\\d+)?)\\, (?<y>(?:\\-)?\\d+(?:\\.\\d+)?)")
	var mat = regex.search(string)
	if mat:
		return Vector2(mat.get_string("x"), mat.get_string("y"))
	return null

static func make_vectors(info:Dictionary):
	for k in info:
		if typeof(info[k]) == TYPE_STRING:
			var vec = string_to_vector2(info[k])
			if vec != null:
				info[k] = vec

static func floats_to_int(dic:Dictionary):
	for k in dic:
		if typeof(dic[k]) == TYPE_REAL:
			dic[k] = int(dic[k])
	return dic

static func renormalize(info:Dictionary):
	for k in info:
		match typeof(info[k]):
			TYPE_STRING:
				var vec = string_to_vector2(info[k])
				if vec != null:
					info[k] = vec
			TYPE_REAL:
				info[k] = int(info[k])
