extends Node3D

const ANIM_BLEND = 0.15
const MOVE_THRESHOLD = 0.0001

@onready var head = $Head
@onready var animator = $Character/AnimationPlayer

var recorded_frames = []

const VANISH_VFX = preload("uid://pa4pb23mf0aa")
var vanish_frame : int
var started_playing_vanish := false

func _ready():
	animator.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_PHYSICS
	animator.play("idle")

func load_recording(frames):
	recorded_frames = frames
	var number_frames := len(recorded_frames)
	vanish_frame = round(number_frames - 0.2 * Engine.physics_ticks_per_second)

func replay_tick(tick):
	if tick >= recorded_frames.size():
		visible = false
		return
	var frame = recorded_frames[tick]
	if tick >= vanish_frame:
		if !started_playing_vanish:
			started_playing_vanish = true
			var vfx : Node3D = VANISH_VFX.instantiate()
			get_tree().root.add_child(vfx)
			vfx.global_position = global_position
	global_position = frame["position"]
	rotation.y = frame["yaw"]
	head.rotation.x = frame["pitch"]
	head.rotation.y = frame["head_yaw"]
	_play_animation("walk" if _is_moving(tick) else "idle")
	if frame["dropped"]:
		var carried = Key.held_by(get_tree(), self)
		if carried:
			carried.drop()
	if frame["target_path"]:
		var target = get_node_or_null(frame["target_path"])
		if target:
			target.report_interaction(self, frame["drag"])

func _is_moving(tick):
	if tick == 0:
		return false
	var here = recorded_frames[tick]["position"]
	var before = recorded_frames[tick - 1]["position"]
	return here.distance_squared_to(before) > MOVE_THRESHOLD

func _play_animation(name):
	if animator.current_animation != name:
		animator.play(name, ANIM_BLEND)
