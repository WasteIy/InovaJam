extends Interactable

@export var target_min : float = 340.0
@export var target_max : float = 360.0
@export var max_angle : float = 360.0
@export var sensitivity : float = 0.5
@export var return_speed : float = 0.0

@export var done_color : Color = Color(0.2, 1, 0.3)
@export var idle_color : Color = Color(0.75, 0.62, 0.25)

@onready var wheel = $Wheel
@onready var rim = $Wheel/Rim

var angle = 0.0

var _material

func setup():
	_material = StandardMaterial3D.new()
	rim.material_override = _material
	_paint()

func grabs():
	return true

func on_turn(_agent, amount):
	angle = clamp(angle + amount * sensitivity, 0.0, max_angle)
	_paint()

func on_hold(count):
	if count > 0 or return_speed <= 0.0 or angle <= 0.0:
		return
	angle = max(angle - return_speed / Engine.physics_ticks_per_second, 0.0)
	_paint()

func is_active():
	return angle >= target_min and angle <= target_max

func progress():
	return angle / max_angle

func reset_state():
	angle = 0.0
	_paint()

func _process(_delta):
	wheel.rotation.z = -deg_to_rad(angle)

func _paint():
	var done = is_active()
	_material.albedo_color = done_color if done else idle_color
	_material.emission_enabled = done
	_material.emission = done_color
