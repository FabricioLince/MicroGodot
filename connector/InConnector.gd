extends "res://connector/Connector.gd"

const kind = Kind.INPUT

func set_input(signals):
	component.set_input(signals, index, size)

func append_connection(c):
	# only allow one connecion on a input connector
	for other_c in component.connections:
		if other_c == null: continue
		if other_c.connected_to == self:
			other_c.on_delete()
	.append_connection(c)
