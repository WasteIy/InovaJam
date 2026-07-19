extends Node3D

## Todos esses têm que reportar is_active() ao mesmo tempo, senão a porta fica fechada
@export var required_parts : Array[NodePath] = []
## O que some quando o conjunto todo tá satisfeito
@export var door : NodePath

func _physics_process(_delta):
	var target = get_node_or_null(door)
	if target == null:
		return
	for path in required_parts:
		if not get_node(path).is_active():
			target.show()
			return
	target.hide()
