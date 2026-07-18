extends Interactable

@export var target_min : float = 135.0
@export var target_max : float = 150.0
@export var max_angle : float = 150.0
@export var sensitivity : float = 1.0
@export var resistance : float = 10.0
@export var return_speed : float = 0.0

@export var done_color : Color = Color(0.2, 1, 0.3)
@export var idle_color : Color = Color(0.85, 0.25, 0.2)

@onready var pivot = $Pivot
@onready var knob = $Pivot/Knob

var angle = 0.0

var _velocity = 0.0
var _material

func setup():
	_material = StandardMaterial3D.new()
	knob.material_override = _material
	_paint()

func grabs():
	return true

func on_drag(_agent, delta):
	_velocity += delta.y * sensitivity

func on_hold(count):
	var step = 1.0 / Engine.physics_ticks_per_second
	_velocity = lerpf(_velocity, 0.0, clampf(resistance * step, 0.0, 1.0))
	var move = _velocity
	if count == 0:
		move -= return_speed
	angle = clampf(angle + move * step, 0.0, max_angle)
	if angle <= 0.0 or angle >= max_angle:
		_velocity = 0.0
	_paint()

func is_active():
	return angle >= target_min and angle <= target_max

func progress():
	return angle / max_angle

func reset_state():
	angle = 0.0
	_velocity = 0.0
	_paint()

func _process(_delta):
	pivot.rotation.z = -deg_to_rad(angle)

func _paint():
	var done = is_active()
	_material.albedo_color = done_color if done else idle_color
	_material.emission_enabled = done
	_material.emission = done_color
