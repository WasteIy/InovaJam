extends Node3D

@onready var head = $Head

var frames = []

func play(recorded):
	frames = recorded

func apply(tick):
	if tick >= frames.size():
		visible = false
		return
	var f = frames[tick]
	global_position = f["pos"]
	rotation.y = f["yaw"]
	head.rotation.x = f["pitch"]
	if f["act"]:
		get_node(f["act"]).report(self)
