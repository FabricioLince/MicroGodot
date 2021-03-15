extends Object
class_name SerializerHelper 

static func string_to_vector2(string):
	var regex = RegEx.new()
	regex.compile("(?<x>(?:\\-)?\\d+(?:\\.\\d+)?)\\, (?<y>(?:\\-)?\\d+(?:\\.\\d+)?)")
	var mat = regex.search(string)
	if mat:
		return Vector2(mat.get_string("x"), mat.get_string("y"))

static func floats_to_int(dic):
	for k in dic:
		if typeof(dic[k]) == TYPE_REAL:
			dic[k] = int(dic[k])
	return dic
