extends Node3D

signal all_complete

var is_complete = false

func _physics_process(_delta):
	if is_complete:
		return
	for child in get_children():
		if child.is_in_group("keys"):
			continue
		if not child.is_active():
			return
	is_complete = true
	TimeLoop.is_running = false
	Reactor.resolve()
	all_complete.emit()
