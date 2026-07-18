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
	if frame["target_path"]:
		get_node(frame["target_path"]).report_interaction(self, frame["drag"])
