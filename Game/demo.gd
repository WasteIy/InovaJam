extends Node3D

func _ready():
	TimeLoop.configure(self, preload("res://Game/Time Loop/clone.tscn"))
	TimeLoop.start()
