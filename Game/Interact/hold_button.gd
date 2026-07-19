extends Interactable

const PRESS_SOUND = preload("res://Assets/Sounds/button_press.wav")
const RELEASE_SOUND = preload("res://Assets/Sounds/button_release.wav")

@export var press_depth : float = 0.02
@export var press_speed : float = 22.0
@export var press_axis : Vector3 = Vector3.UP

@onready var cap = $Cap
@onready var audio_player = $AudioPlayer

var is_pressed = false

var _rest_position = Vector3.ZERO
var _press_dir = Vector3.UP

func setup():
	_rest_position = cap.position
	_press_dir = (cap.transform.basis * press_axis).normalized()

func on_hold(holder_count):
	var pressed = holder_count > 0
	if pressed != is_pressed:
		audio_player.stream = PRESS_SOUND if pressed else RELEASE_SOUND
		audio_player.play()
	is_pressed = pressed

func is_active():
	return is_pressed

func reset_state():
	is_pressed = false

func _process(delta):
	var target = _rest_position
	if is_pressed:
		target += _press_dir * press_depth
	cap.position = cap.position.lerp(target, clampf(delta * press_speed, 0.0, 1.0))
