class_name Player
extends CharacterBody3D

const MOUSE_SENSITIVITY = 0.0025
const MOVE_SPEED = 4.0

@onready var head = $Head
@onready var interact_ray = $Head/Ray

## Uma entrada por tick de física: diz aonde a gente tava, aonde tava olhando, no que tava mexendo
var recorded_frames = []

## Caminho do que a gente tá usando nesse tick, null quando a mão tá vazia
var _target_path
## Movimento de mouse repassado pras coisas de agarrar, tipo alavanca e válvula
var _drag = Vector2.ZERO
## Verdadeiro enquanto segura algo que come o mouse em vez de virar a câmera
var _is_grabbing = false
## Movimento de mouse acumulado desde o último tick de física
var _mouse_motion = Vector2.ZERO
## Onde a gente começou, pra todo rewind largar no mesmo lugar
var _spawn_position
var _spawn_yaw

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	TimeLoop.player_recorder = self
	_spawn_position = global_position
	_spawn_yaw = rotation.y

func capture_frame():
	recorded_frames.append({
		"position": global_position,
		"yaw": rotation.y,
		"pitch": head.rotation.x,
		"target_path": _target_path,
		"drag": _drag,
	})

func reset_to_spawn():
	recorded_frames = []
	global_position = _spawn_position
	rotation.y = _spawn_yaw
	velocity = Vector3.ZERO
	head.rotation.x = 0

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		_mouse_motion += event.relative
		if not _is_grabbing:
			rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
			head.rotation.x = clamp(head.rotation.x - event.relative.y * MOUSE_SENSITIVITY, -1.5, 1.5)
	if event.is_action_pressed("rewind"):
		TimeLoop.rewind_loop()

func _physics_process(delta):
	var input = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = transform.basis * Vector3(input.x, 0, input.y)
	velocity.x = direction.x * MOVE_SPEED
	velocity.z = direction.z * MOVE_SPEED
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	move_and_slide()

	_target_path = null
	_drag = Vector2.ZERO
	_is_grabbing = false
	if Input.is_action_pressed("interact") and interact_ray.is_colliding():
		var target = interact_ray.get_collider()
		if target is Interactable:
			_target_path = target.get_path()
			_is_grabbing = target.uses_mouse_drag()
			if _is_grabbing:
				_drag = _mouse_motion
			target.report_interaction(self, _drag)
	_mouse_motion = Vector2.ZERO
