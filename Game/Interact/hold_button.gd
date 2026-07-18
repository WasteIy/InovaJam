extends Interactable

@export var pressed_color : Color = Color(0.2, 1, 0.3)
@export var idle_color : Color = Color(0.8, 0.2, 0.2)

@onready var mesh = $Body/Mesh

var pressed = false

var _material

func _ready():
	super._ready()
	_material = StandardMaterial3D.new()
	mesh.material_override = _material
	_paint(false)

func evaluate(count):
	var now = count > 0
	if now != pressed:
		pressed = now
		_paint(now)

func reset_state():
	pressed = false
	_paint(false)

func _paint(on):
	_material.albedo_color = pressed_color if on else idle_color
	_material.emission_enabled = on
	_material.emission = pressed_color
