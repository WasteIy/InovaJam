extends Node3D

var cam : Camera3D
@onready var anim: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	anim.animation_finished.connect(anim_finished)
	cam = get_viewport().get_camera_3d()
	var cam_pos = cam.global_position
	cam_pos.y = global_position.y
	look_at(cam_pos)

func anim_finished(_name : StringName):
	queue_free()

func _process(_delta: float) -> void:
	var cam_pos = cam.global_position
	cam_pos.y = global_position.y
	look_at(cam_pos)
