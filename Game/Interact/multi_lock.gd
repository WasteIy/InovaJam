extends Node3D

@export var buttons : Array[NodePath] = []
@export var door : NodePath

func _physics_process(_delta):
	for path in buttons:
		if not get_node(path).pressed:
			get_node(door).show()
			return
	get_node(door).hide()
