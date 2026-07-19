class_name Player
extends CharacterBody3D

const MOUSE_SENSITIVITY = 0.0025
const MOVE_SPEED = 4.0
const ANIM_BLEND = 0.15
## Quanto a cabeça pode torcer antes do corpo ser arrastado junto
const MAX_HEAD_YAW = 60.0
## Quão rápido o corpo se alinha ao olhar enquanto anda
const BODY_TURN_SPEED = 6.0

@onready var head = $Head
@onready var interact_ray = $Head/Ray
@onready var animator = $Character/AnimationPlayer

## Uma entrada por tick de física: diz aonde a gente tava, aonde tava olhando, no que tava mexendo
var recorded_frames = []

## Pra onde a câmera aponta. O corpo persegue isso, mas com atraso
var look_yaw = 0.0

## Caminho do que a gente tá usando nesse tick, null quando a mão tá vazia
var _target_path
## Movimento de mouse repassado pras coisas de agarrar, tipo alavanca e válvula
var _drag = Vector2.ZERO
## Verdadeiro enquanto segura algo que come o mouse em vez de virar a câmera
var _is_grabbing = false
## Movimento de mouse acumulado desde o último tick de física
var _mouse_motion = Vector2.ZERO
var _dropped = false
## Onde a gente começou, pra todo rewind largar no mesmo lugar
var _spawn_position
var _spawn_yaw

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	interact_ray.add_exception(self)
	TimeLoop.player_recorder = self
	_spawn_position = global_position
	_spawn_yaw = rotation.y
	look_yaw = rotation.y
	animator.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_PHYSICS
	play_animation("idle")

func play_animation(name):
	if animator.current_animation != name:
		animator.play(name, ANIM_BLEND)

func _turn_body(moving, delta):
	var limit = deg_to_rad(MAX_HEAD_YAW)
	var offset = wrapf(look_yaw - rotation.y, -PI, PI)
	if absf(offset) > limit:
		rotation.y += offset - signf(offset) * limit
	if moving:
		rotation.y = lerp_angle(rotation.y, look_yaw, clampf(delta * BODY_TURN_SPEED, 0.0, 1.0))
	head.rotation.y = wrapf(look_yaw - rotation.y, -PI, PI)

func capture_frame():
	recorded_frames.append({
		"position": global_position,
		"yaw": rotation.y,
		"pitch": head.rotation.x,
		"head_yaw": head.rotation.y,
		"target_path": _target_path,
		"drag": _drag,
		"dropped": _dropped,
	})

func reset_to_spawn():
	recorded_frames = []
	global_position = _spawn_position
	rotation.y = _spawn_yaw
	look_yaw = _spawn_yaw
	velocity = Vector3.ZERO
	head.rotation = Vector3.ZERO

func _unhandled_input(event):
	if event.is_action_pressed("Esc"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		return
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseButton and event.pressed:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		return
	if event is InputEventMouseMotion:
		_mouse_motion += event.relative
		if not _is_grabbing:
			look_yaw -= event.relative.x * MOUSE_SENSITIVITY
			head.rotation.x = clamp(head.rotation.x - event.relative.y * MOUSE_SENSITIVITY, -1.5, 1.5)
			head.rotation.y = wrapf(look_yaw - rotation.y, -PI, PI)
	if event.is_action_pressed("rewind"):
		TimeLoop.rewind_loop()

func _physics_process(delta):
	var input = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = Vector3(input.x, 0, input.y).rotated(Vector3.UP, look_yaw)
	velocity.x = direction.x * MOVE_SPEED
	velocity.z = direction.z * MOVE_SPEED
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	move_and_slide()
	_turn_body(input != Vector2.ZERO, delta)
	play_animation("walk" if input != Vector2.ZERO else "idle")

	_dropped = false
	if Input.is_action_just_pressed("drop"):
		var carried = Key.held_by(get_tree(), self)
		if carried:
			carried.drop()
			_dropped = true

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
