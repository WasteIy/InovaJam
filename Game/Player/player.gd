class_name Player
extends CharacterBody3D

const MOUSE_SENSITIVITY = 0.0025
const SPEED = 4.0

@onready var head = $Head
@onready var ray = $Head/Ray

var frames = []
var _action
var _spawn_position
var _spawn_yaw

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	TimeLoop.recorder = self
	_spawn_position = global_position
	_spawn_yaw = rotation.y

func capture():
	frames.append({
		"pos": global_position,
		"yaw": rotation.y,
		"pitch": head.rotation.x,
		"act": _action,
	})

func reset():
	frames = []
	global_position = _spawn_position
	rotation.y = _spawn_yaw
	velocity = Vector3.ZERO
	head.rotation.x = 0

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		head.rotation.x = clamp(head.rotation.x - event.relative.y * MOUSE_SENSITIVITY, -1.5, 1.5)
	if event.is_action_pressed("rewind"):
		TimeLoop.rewind()

func _physics_process(delta):
	var input = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var dir = transform.basis * Vector3(input.x, 0, input.y)
	velocity.x = dir.x * SPEED
	velocity.z = dir.z * SPEED
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	move_and_slide()

	_action = null
	if Input.is_action_pressed("interact") and ray.is_colliding():
		var target = ray.get_collider().get_parent()
		if target is Interactable:
			_action = target.get_path()
			target.report(self)
