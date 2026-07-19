extends Node3D

func _ready():
	TimeLoop.setup_clones(self, preload("res://Game/Time Loop/clone.tscn"))
	TimeLoop.start_run()

func _unhandled_input(event):
	if event.is_action_pressed("restart"):
		TimeLoop.is_running = false
		Reactor.is_resolved = false
		Reactor.current_phase = Reactor.Phase.CALM
		get_tree().reload_current_scene()
