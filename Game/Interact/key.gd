class_name Key
extends Interactable

const TOSS_SPEED = 2.0
const TOSS_LIFT = 1.5
const TUMBLE = 2.5

@onready var collision = $Collision

var body

var holder
var socket
var is_temporal = false
var is_loose = false
var run_index = -1

var _spawn_transform

static func held_by(tree, agent):
	for key in tree.get_nodes_in_group("keys"):
		if key.holder == agent:
			return key
	return null

func setup():
	body = self
	add_to_group("keys")
	_spawn_transform = global_transform
	_refresh()

func on_press(agent):
	if holder or socket:
		return
	holder = agent
	is_loose = false
	_refresh()

func give_to(agent):
	holder = agent
	socket = null
	is_loose = false
	_refresh()

func drop():
	var forward = -holder.global_transform.basis.z
	var start = Transform3D(Basis(Vector3.UP, holder.rotation.y), holder.global_position + Vector3.UP * 1.1 + forward * 0.5)
	holder = null
	is_loose = true
	_teleport(start)
	_refresh()
	body.linear_velocity = forward * TOSS_SPEED + Vector3.UP * TOSS_LIFT
	body.angular_velocity = Vector3(TUMBLE, TUMBLE * 0.5, 0.0)

func insert(into):
	holder = null
	socket = into
	is_loose = false
	_refresh()

func reset_state():
	if holder == TimeLoop.player_recorder:
		_hand_copy_to_player()
	if is_temporal:
		return
	holder = null
	socket = null
	is_loose = false
	_teleport(_spawn_transform)
	_refresh()

func _teleport(target):
	global_transform = target
	PhysicsServer3D.body_set_state(get_rid(), PhysicsServer3D.BODY_STATE_TRANSFORM, target)
	PhysicsServer3D.body_set_state(get_rid(), PhysicsServer3D.BODY_STATE_LINEAR_VELOCITY, Vector3.ZERO)
	PhysicsServer3D.body_set_state(get_rid(), PhysicsServer3D.BODY_STATE_ANGULAR_VELOCITY, Vector3.ZERO)

func _hand_copy_to_player():
	var copy = duplicate()
	get_parent().add_child(copy)
	copy.is_temporal = true
	copy.run_index = TimeLoop.past_recordings.size()
	copy.holder = TimeLoop.player_recorder
	copy._refresh()

func _refresh():
	var carried = holder != null or socket != null
	visible = socket != null or holder == null
	body.freeze = carried or not is_loose
	collision.set_deferred("disabled", carried)
