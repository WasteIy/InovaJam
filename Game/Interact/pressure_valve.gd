extends Interactable

const SPEED = 0.05
const MAX_ANGLE = 1.1
const GREEN_ZONE = 0.25
const STRIKES_TO_STABILIZE = 3

const ON_COLOR = Color(0.2, 1, 0.3)
const OFF_COLOR = Color(0.12, 0.12, 0.14)

@onready var needle = $Needle
@onready var lights = $Lights.get_children()

var stabilized = false

var _strikes = 0
var _materials = []

func _ready():
	super._ready()
	for light in lights:
		var material = StandardMaterial3D.new()
		light.material_override = material
		_materials.append(material)
	_paint_lights()

func report(agent):
	var held = _reports.has(agent) and _reports[agent] >= TimeLoop.tick - 1
	super.report(agent)
	if not held:
		_press()

func reset_state():
	stabilized = false
	_strikes = 0
	_paint_lights()

func _physics_process(delta):
	super._physics_process(delta)
	needle.rotation.z = -_offset() * MAX_ANGLE

func _offset():
	if stabilized:
		return 0.0
	return sin(TimeLoop.tick * SPEED)

func _press():
	if stabilized or absf(_offset()) > GREEN_ZONE:
		return
	_strikes += 1
	if _strikes >= STRIKES_TO_STABILIZE:
		stabilized = true
	_paint_lights()

func _paint_lights():
	for i in _materials.size():
		var on = i < _strikes
		_materials[i].albedo_color = ON_COLOR if on else OFF_COLOR
		_materials[i].emission_enabled = on
		_materials[i].emission = ON_COLOR
