class_name WireTerminal
extends Interactable

const WIRE_COLORS = [
	Color(0.9, 0.22, 0.2),
	Color(0.95, 0.78, 0.2),
	Color(0.25, 0.5, 1.0),
	Color(0.3, 0.9, 0.42),
	Color(0.82, 0.35, 0.9),
]

const IDLE_ENERGY = 0.12
const LIVE_ENERGY = 0.7

const SELECTED_ENERGY = 0.7

@export var wire_id : int = 0 : set = _set_wire_id
@export var is_source : bool = true

var is_wired = false
var is_selected = false

var _material

func wire_color():
	return WIRE_COLORS[wire_id % WIRE_COLORS.size()]

func setup():
	_material = StandardMaterial3D.new()
	_material.emission_enabled = true
	$Mesh.material_override = _material
	_refresh_glow()

func on_press(agent):
	get_parent().on_terminal_pressed(self, agent)

func set_state(wired, picked):
	is_wired = wired
	is_selected = picked
	_refresh_glow()

func reset_state():
	is_wired = false
	is_selected = false
	_refresh_glow()

func _set_wire_id(value):
	wire_id = value
	_refresh_glow()

func _refresh_glow():
	if _material == null:
		return
	var energy = IDLE_ENERGY
	if is_wired:
		energy = LIVE_ENERGY
	elif is_selected:
		energy = SELECTED_ENERGY
	_material.albedo_color = wire_color()
	_material.emission = wire_color()
	_material.emission_energy_multiplier = energy
