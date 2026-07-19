class_name TvScene
extends Label

const DONE_COLOR = Color(0.2, 0.9, 0.3)

@export var time_value: float:
	set(value):
		time_value = value
		var total = maxf(value, 0.0)
		text = "%02d.%02d" % [int(total), int(total * 100) % 100]

var _is_green = false

func _process(_delta):
	if Reactor.is_resolved:
		if not _is_green:
			_is_green = true
			add_theme_color_override("font_color", DONE_COLOR)
		return
	var elapsed = TimeLoop.current_tick / float(Engine.physics_ticks_per_second)
	time_value = TimeLoop.loop_duration_seconds - elapsed
