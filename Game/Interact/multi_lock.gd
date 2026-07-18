extends Node3D

@export var parts : Array[NodePath] = []
@export var door : NodePath

func _physics_process(_delta):
	for path in parts:
		if not get_node(path).is_active():
			get_node(door).show()
			return
	get_node(door).hide()
