class_name Interactable
extends StaticBody3D

var _reports = {}

func _ready():
	TimeLoop.loop_reset.connect(_on_loop_reset)
	setup()

func report(agent, turn = 0.0):
	var was_held = _reports.has(agent) and _reports[agent] >= TimeLoop.tick - 1
	_reports[agent] = TimeLoop.tick
	if not was_held:
		on_press(agent)
	if turn != 0.0:
		on_turn(agent, turn)

func setup():
	pass

func grabs():
	return false

func on_press(_agent):
	pass

func on_hold(_count):
	pass

func on_turn(_agent, _amount):
	pass

func is_active():
	return false

func reset_state():
	pass

func _physics_process(_delta):
	var count = 0
	for agent in _reports.keys():
		if _reports[agent] >= TimeLoop.tick - 1:
			count += 1
		else:
			_reports.erase(agent)
	on_hold(count)

func _on_loop_reset():
	_reports.clear()
	reset_state()
