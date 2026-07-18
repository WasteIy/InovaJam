extends Node3D

func _ready():
	TimeLoop.setup_clones(self, preload("res://Game/Time Loop/clone.tscn"))
	TimeLoop.start_run()
