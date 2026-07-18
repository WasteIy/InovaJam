extends Interactable

@export var pressed_color : Color = Color(0.2, 1, 0.3)
@export var idle_color : Color = Color(0.8, 0.2, 0.2)

@onready var mesh = $Mesh

var pressed = false

var _material

func setup():
	_material = StandardMaterial3D.new()
	mesh.material_override = _material
	_paint(false)

func on_hold(count):
	var now = count > 0
	if now != pressed:
		pressed = now
		_paint(now)

func is_active():
	return pressed

func reset_state():
	pressed = false
	_paint(false)

func _paint(on):
	_material.albedo_color = pressed_color if on else idle_color
	_material.emission_enabled = on
	_material.emission = pressed_color
