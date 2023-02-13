extends "res://connector/Connector.gd"

const kind = Kind.OUTPUT
var listeners := []

# queries the component to receive the signals associated with this connector
func get_signals() -> Array:
	var signals = component.get_output()
	return signals.slice(index, index+size-1)

# callback to component to pass the signals associated with this connector
func set_signals(signals:Array):
	#print(descr(), "'s signal = ", signals)
	for l in listeners:
		if l.is_valid():
			l.call_func(signals)

