extends Interactable

@export_group("Sin config")
@export var max_amp = 0.5
@export var max_freq = 40.0
var actual_freq = 38.0
var actual_amp = 0.12

var red_freq : float
var red_amp : float

@export_group("Mouse config")
@export var mouse_sensitivity : float = 1.0

@onready var screen: MeshInstance3D = $Screen
var screen_material : ShaderMaterial

var speed : Vector2

func setup():
	screen_material = screen.material_override.duplicate()
	screen.material_override = screen_material
	red_freq = randf_range(0, max_freq)
	red_amp = randf_range(0, max_amp)
	screen_material.set_shader_parameter("red_freq", red_freq)
	screen_material.set_shader_parameter("red_amp", red_amp)

func uses_mouse_drag():
	return true

func on_drag(_agent, _drag):
	speed = _drag * mouse_sensitivity * 0.0005
	var change : Vector2 = Vector2(max_freq * speed.x, max_amp * speed.y)
	actual_freq = clampf(actual_freq + change.x, -max_freq, max_freq)
	actual_amp = clampf(actual_amp + change.y, -max_amp, max_amp)
	screen_material.set_shader_parameter("green_freq", actual_freq)
	screen_material.set_shader_parameter("green_amp", actual_amp)

func is_active():
	var dif_freq = abs(actual_freq) - red_freq
	var dif_amp = abs(actual_amp) - red_amp
	return dif_freq < 1.0 and dif_amp < 0.05 
