extends "res://components/chips/ScriptChip/ScriptChipBase.gd"

#-- input/output especification
var input_spec = {on = 1, interval = 8}
var output_spec = {tick = 1}

var on = true
var timer = 1.0
var state = false
var wait_timer = 0

#-- called when this gate is instantiated
func on_load():
	set_label("Clock")
	set_output({tick = state})
	timer = wait_timer

#-- called when gate input changes
func on_set_input():
	var input = get_input()
	on = input.on != 0
	calc_wait_timer(input.interval)

#-- called every frame of the simulation
func loop(delta):
	if on:
		timer -= delta
		if timer < 0.0:
			timer += wait_timer
			state = !state
			set_output({tick = state})

func calc_wait_timer(interval):
	interval = Signal.List.to_number(interval)
	if interval <= 0:
		wait_timer = 0
	else:
		wait_timer = 1.0/float(interval)
