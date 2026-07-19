extends Interactable

@export var solved_angle_min : float = 135.0
@export var solved_angle_max : float = 150.0
@export var max_angle : float = 150.0
@export var drag_sensitivity : float = 1.0
@export var friction : float = 10.0
@export var return_speed : float = 0.0

@export var solved_color : Color = Color(0.2, 1, 0.3)
@export var idle_color : Color = Color(0.85, 0.25, 0.2)

@onready var pivot = $Pivot
@onready var knob = $Pivot/Knob

@onready var audio_player: AudioStreamPlayer3D = $AudioPlayer

var was_active = false

## Onde a alavanca tá agora, em graus
var current_angle = 0.0

## Graus por segundo que ela tá se movendo no momento
var _angular_velocity = 0.0
var _material

func setup():
	_material = StandardMaterial3D.new()
	knob.material_override = _material
	_refresh_color()

func uses_mouse_drag():
	return true

func on_drag(_agent, drag):
	_angular_velocity += drag.y * drag_sensitivity

func on_hold(holder_count):
	var step = 1.0 / Engine.physics_ticks_per_second
	_angular_velocity = lerpf(_angular_velocity, 0.0, clampf(friction * step, 0.0, 1.0))
	var move = _angular_velocity
	if holder_count == 0:
		move -= return_speed
	current_angle = clampf(current_angle + move * step, 0.0, max_angle)
	if current_angle <= 0.0 or current_angle >= max_angle:
		_angular_velocity = 0.0
	
	if is_active():
		if !was_active:
			was_active = true
			audio_player.play()
	else:
		was_active = false
	
	_refresh_color()

func is_active():
	return current_angle >= solved_angle_min and current_angle <= solved_angle_max

func progress():
	return current_angle / max_angle

func reset_state():
	current_angle = 0.0
	_angular_velocity = 0.0
	_refresh_color()

func _process(_delta):
	pivot.rotation.z = -deg_to_rad(current_angle)

func _refresh_color():
	var solved = is_active()
	_material.albedo_color = solved_color if solved else idle_color
	_material.emission_enabled = solved
	_material.emission = solved_color
