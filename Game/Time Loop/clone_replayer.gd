extends Node3D

@onready var head = $Head

var recorded_frames = []

func load_recording(frames):
	recorded_frames = frames

func replay_tick(tick):
	if tick >= recorded_frames.size():
		visible = false
		return
	var frame = recorded_frames[tick]
	global_position = frame["position"]
	rotation.y = frame["yaw"]
	head.rotation.x = frame["pitch"]
	if frame["dropped"]:
		var carried = Key.held_by(get_tree(), self)
		if carried:
			carried.drop()
	if frame["target_path"]:
		var target = get_node_or_null(frame["target_path"])
		if target:
			target.report_interaction(self, frame["drag"])
