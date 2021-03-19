extends Node

signal done_fixing(all_done)

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

func fix_dependency_on_cache(old_path, new_path):
	var new_cache = {}
	for file_path in cache:
		var all = get_json(file_path)
		for chip in all.chips:
			if chip.type == "ComplexChip" and chip.path == old_path:
				chip.path = new_path
				print(chip)
				var content = JSON.print(all, "\t")
				new_cache[file_path] = content
	for file_path in new_cache:
		save_on(file_path, new_cache[file_path])

func get_json(path):
	var content = load_from(path)
	if content:
		return JSON.parse(content).result

var dependency_errors = []

func add_dependency_error(path):
	if not dependency_errors.has(path):
		dependency_errors.append(path)

func prompt_fix_dependency_errors():
	if dependency_errors.size() > 0:
		print("dependency errors: ")
		print(dependency_errors)
		for old_path in dependency_errors:
			MessageSystem.popup.prompt_confirmation("please provide new path for\n'%s'"%old_path, "Dependency Error")
			var r = yield(MessageSystem.popup, "button_pressed")
			if r == 0:
				MessageSystem.file_dialog.prompt_select_file()
				var new_path = yield(MessageSystem.file_dialog, "done_selecting")
				if new_path:
					print("fixing dependencies on cache:")
					new_path = Global.complex_chip_local_path(new_path).replace(".chip", "")
					print("%s -> %s"%[old_path, new_path])
					fix_dependency_on_cache(old_path, new_path)
					dependency_errors.erase(old_path)
		emit_signal("done_fixing", dependency_errors.size()==0)
		return true
