extends Interactable

const PRESS_SOUND = preload("res://Assets/Sounds/button_press.wav")
const RELEASE_SOUND = preload("res://Assets/Sounds/button_release.wav")

@export var press_depth : float = 0.02
@export var press_speed : float = 22.0

@onready var cap = $Cap
@onready var audio_player = $AudioPlayer

## Verdadeiro sempre que pelo menos um clone tá segurando isso
var is_pressed = false

var _rest_z = 0.0

func setup():
	_rest_z = cap.position.z

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
	var target = _rest_z
	if is_pressed:
		target -= press_depth
	cap.position.z = lerpf(cap.position.z, target, clampf(delta * press_speed, 0.0, 1.0))
