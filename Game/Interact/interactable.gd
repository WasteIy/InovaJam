class_name Interactable
extends Node3D

var _reports = {}

func _ready():
	TimeLoop.loop_reset.connect(_on_loop_reset)

func report(agent):
	_reports[agent] = TimeLoop.tick

func evaluate(_count):
	pass

func reset_state():
	pass

func _physics_process(_delta):
	var count = 0
	for agent in _reports.keys():
		if _reports[agent] >= TimeLoop.tick - 1:
			count += 1
		else:
			_reports.erase(agent)
	evaluate(count)

func _on_loop_reset():
	_reports.clear()
	reset_state()
