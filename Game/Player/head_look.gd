extends Node3D

@export var bone_name : String = "mixamorig_Head"
## Nó cuja rotação a cabeça copia, normalmente o Head que a câmera segue
@export var look_source : NodePath

@export var max_pitch : float = 55.0
@export var max_yaw : float = 70.0

## Em que eixo local do osso cada giro acontece, muda conforme o rig
@export var pitch_axis : Vector3 = Vector3.LEFT
@export var yaw_axis : Vector3 = Vector3.UP

var _skeleton
var _source
var _bone = -1
var _rest

func _ready():
	_skeleton = get_parent()
	_source = get_node_or_null(look_source)
	_bone = _skeleton.find_bone(bone_name)
	_rest = _skeleton.get_bone_rest(_bone).basis.get_rotation_quaternion()

func _process(_delta):
	var pitch = clampf(_source.rotation.x, -deg_to_rad(max_pitch), deg_to_rad(max_pitch))
	var yaw = clampf(_source.rotation.y, -deg_to_rad(max_yaw), deg_to_rad(max_yaw))
	var extra = Quaternion(pitch_axis.normalized(), pitch) * Quaternion(yaw_axis.normalized(), yaw)
	_skeleton.set_bone_pose_rotation(_bone, _rest * extra)
