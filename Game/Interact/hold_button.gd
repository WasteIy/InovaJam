extends Interactable

@export var pressed_color : Color = Color(0.2, 1, 0.3)
@export var idle_color : Color = Color(0.8, 0.2, 0.2)

@onready var mesh = $Mesh

## Verdadeiro sempre que pelo menos um clone tá segurando isso
var is_pressed = false

var _material

func setup():
	_material = StandardMaterial3D.new()
	mesh.material_override = _material
	_refresh_color(false)

func on_hold(holder_count):
	var held_now = holder_count > 0
	if held_now != is_pressed:
		is_pressed = held_now
		_refresh_color(held_now)

func is_active():
	return is_pressed

func reset_state():
	is_pressed = false
	_refresh_color(false)

func _refresh_color(lit):
	_material.albedo_color = pressed_color if lit else idle_color
	_material.emission_enabled = lit
	_material.emission = pressed_color
