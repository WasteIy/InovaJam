extends AudioStreamPlayer3D

var _last_second = -1

func _process(_delta):
	if Reactor.is_resolved or not TimeLoop.is_running:
		return
	var second = TimeLoop.current_tick / Engine.physics_ticks_per_second
	if second == _last_second:
		return
	_last_second = second
	play()
