extends Node


var cache = {}

func load_from(path):
	if cache.has(path):
		#print("cache hit ", path)
		return cache[path]
	#print("cache miss ", path)
	var file = File.new()
	file.open(path, File.READ)
	if file.is_open():
		var content = file.get_as_text()
		file.close()
		cache[path] = content
		return content

func save_on(path, content):
	var file = File.new()
	file.open(path, File.WRITE)
	if file.is_open():
		file.store_string(content)
		file.close()
		cache[path] = content
		return true
