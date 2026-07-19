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
	_refresh()

func drop():
	var forward = -holder.global_transform.basis.z
	global_position = holder.global_position + Vector3.UP * 1.1 + forward * 0.5
	global_rotation = Vector3(0.0, holder.rotation.y, 0.0)
	holder = null
	_refresh()
	body.linear_velocity = forward * TOSS_SPEED + Vector3.UP * TOSS_LIFT
	body.angular_velocity = Vector3(TUMBLE, TUMBLE * 0.5, 0.0)

func insert(into):
	holder = null
	socket = into
	_refresh()

func reset_state():
	if holder == TimeLoop.player_recorder:
		if not is_temporal:
			_refill_pedestal()
			is_temporal = true
		return
	if is_temporal:
		queue_free()
		return
	holder = null
	socket = null
	_refresh()
	global_transform = _spawn_transform
	body.linear_velocity = Vector3.ZERO
	body.angular_velocity = Vector3.ZERO

func _refill_pedestal():
	var fresh = duplicate()
	fresh.transform = _spawn_transform
	get_parent().add_child(fresh)

func _refresh():
	var carried = holder != null or socket != null
	visible = socket != null or holder == null
	body.freeze = carried
	collision.set_deferred("disabled", carried)
