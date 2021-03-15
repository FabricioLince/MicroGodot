extends CenterContainer

onready var progress = $TextureProgress

var total = 1.0 setget set_total
var count = 0.0 setget set_count

func set_total(total_):
	total = float(total_)
	count = 0.0
	show()

func increment():
	set_count(count+1)

func set_count(count_):
	count = float(count_)
	show()
	set_ratio(count/total)

func set_ratio(ratio:float):
	progress.ratio = ratio
	if progress.ratio == 1:
		hide()
