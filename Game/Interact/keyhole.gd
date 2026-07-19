extends Interactable

@export var solved_angle_min : float = 85.0
@export var solved_angle_max : float = 90.0
@export var max_angle : float = 90.0
@export var drag_sensitivity : float = 1.0
@export var friction : float = 10.0
@export var return_speed : float = 60.0

@export var solved_color : Color = Color(0.2, 1, 0.3)
@export var idle_color : Color = Color(0.7, 0.65, 0.3)

@onready var slot = $Slot
@onready var barrel = $Slot/Barrel
@onready var insert_point = $Slot/Insert

var inserted_key
var current_angle = 0.0

var _angular_velocity = 0.0
var _material

func setup():
	_material = StandardMaterial3D.new()
	barrel.material_override = _material
	_refresh_color()

func uses_mouse_drag():
	return inserted_key != null

func on_press(agent):
	if inserted_key:
		return
	var key = Key.held_by(get_tree(), agent)
	if key:
		inserted_key = key
		key.insert(self)

func on_drag(_agent, drag):
	if inserted_key:
		_angular_velocity += drag.x * drag_sensitivity

func on_hold(holder_count):
	var step = 1.0 / Engine.physics_ticks_per_second
	_angular_velocity = lerpf(_angular_velocity, 0.0, clampf(friction * step, 0.0, 1.0))
	var move = _angular_velocity
	if holder_count == 0:
		move -= return_speed
	current_angle = clampf(current_angle + move * step, 0.0, max_angle)
	if current_angle <= 0.0 or current_angle >= max_angle:
		_angular_velocity = 0.0
	_refresh_color()

func is_active():
	return current_angle >= solved_angle_min and current_angle <= solved_angle_max

func reset_state():
	inserted_key = null
	current_angle = 0.0
	_angular_velocity = 0.0
	_refresh_color()

func _process(_delta):
	slot.rotation.z = -deg_to_rad(current_angle)
	if inserted_key:
		inserted_key.global_transform = insert_point.global_transform

func _refresh_color():
	var solved = is_active()
	_material.albedo_color = solved_color if solved else idle_color
	_material.emission_enabled = solved
	_material.emission = solved_color
