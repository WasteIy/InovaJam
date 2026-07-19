class_name TvScene
extends Label

@export var time_value: float:
	set(value):
		time_value = value
		var total = maxf(value, 0.0)
		text = "%02d.%02d" % [int(total), int(total * 100) % 100]

func _process(_delta):
	var elapsed = TimeLoop.current_tick / float(Engine.physics_ticks_per_second)
	time_value = TimeLoop.loop_duration_seconds - elapsed
