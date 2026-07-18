class_name Interactable
extends StaticBody3D

## Último tick em que cada clone encostou, indexado pelo nó do player ou do clone
var _last_touch_tick = {}

func _ready():
	TimeLoop.loop_reset.connect(_on_loop_reset)
	setup()

func report_interaction(agent, drag = Vector2.ZERO):
	var was_holding = _last_touch_tick.has(agent) and _last_touch_tick[agent] >= TimeLoop.current_tick - 1
	_last_touch_tick[agent] = TimeLoop.current_tick
	if not was_holding:
		on_press(agent)
	if drag != Vector2.ZERO:
		on_drag(agent, drag)

func setup():
	pass

func uses_mouse_drag():
	return false

func on_press(_agent):
	pass

func on_hold(_holder_count):
	pass

func on_drag(_agent, _drag):
	pass

func is_active():
	return false

func reset_state():
	pass

func _physics_process(_delta):
	var holder_count = 0
	for agent in _last_touch_tick.keys():
		if _last_touch_tick[agent] >= TimeLoop.current_tick - 1:
			holder_count += 1
		else:
			_last_touch_tick.erase(agent)
	on_hold(holder_count)

func _on_loop_reset():
	_last_touch_tick.clear()
	reset_state()
