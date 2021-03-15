extends Node2D

const InConnector = preload("res://connector/InConnector.tscn")
const OutConnector = preload("res://connector/OutConnector.tscn")

var component
var in_connectors = []
var out_connectors = []

const MIN_DELTA = 64.0/4

func initialize(input_sizes, output_sizes):
	initialize_input_connectors(input_sizes)
	initialize_output_connectors(output_sizes)

func initialize_output_connectors(output_sizes):
	create_connectors(output_sizes, out_connectors, OutConnector)
	position_connectors(in_connectors, -32)
	position_connectors(out_connectors, 32)
func initialize_input_connectors(input_sizes):
	create_connectors(input_sizes, in_connectors, InConnector)
	position_connectors(in_connectors, -32)
	position_connectors(out_connectors, 32)

func create_connectors(sizes, connector_list, Connector):
	if component == null:
		component = get_parent()
	if not compare_spec(sizes, connector_list):
		# only redo the connections if the specification is different
		# from the connectors already here
		return
	for inc in connector_list:
		inc.queue_free()
	connector_list.clear()
	var index = 0
	for size in sizes:
		var con = Connector.instance()
		con.index = index
		con.size = size
		con.component = component
		connector_list.append(con)
		add_child(con)
		#print("created ", con.descr())
		index += size

func position_connectors(connector_list, x_pos):
	var io_size = max(in_connectors.size(), out_connectors.size())
	if io_size%2 == 0: io_size += 1
	var size = (io_size+1) * MIN_DELTA
	
	if component.has_method("set_size"):
		component.set_size(Vector2(64, size))
	
	var div = connector_list.size()+1
	if div % 2 == 1: div += 1
	
	var y_delta = MIN_DELTA
	var y = size/2.0 - y_delta
	
	for con in connector_list:
		con.position = Vector2(x_pos, y)
		y -= y_delta


#-- if there's any difference between the specification and the 
#-- connectors already in place, returns true
static func compare_spec(spec_sizes, connector_list):
	if spec_sizes.size() != connector_list.size():
		return true
	for i in range(connector_list.size()):
		if connector_list[i].size != spec_sizes[i]:
			return true
	return false

func get_out_connector_by_index(cumulative_index):
	return get_connector_by_index(out_connectors, cumulative_index)
func get_in_connector_by_index(cumulative_index):
	return get_connector_by_index(in_connectors, cumulative_index)
static func get_connector_by_index(connector_list, cumulative_index):
	for c in connector_list:
		if cumulative_index == 0:
			return c
		cumulative_index -= c.size

func set_input_names(input_names):
	for i in range(in_connectors.size()):
		in_connectors[i].label = input_names[i]
func set_output_names(output_names):
	for i in range(out_connectors.size()):
		out_connectors[i].label = output_names[i]

func get_input_label(cumulative_index):
	var con = get_connector_by_index(in_connectors, cumulative_index)
	if con: return con.label
func get_output_label(cumulative_index):
	var con = get_connector_by_index(out_connectors, cumulative_index)
	if con: return con.label
