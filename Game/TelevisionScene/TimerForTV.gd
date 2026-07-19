class_name TvScene
extends Label

@export var time_value: float:
	set(value):
		time_value = value
		var total = maxf(value, 0.0)
		text = "%02d.%02d" % [int(total), int(total * 100) % 100]
