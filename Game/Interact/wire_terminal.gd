class_name WireTerminal
extends Interactable

const COLORS = [
	Color(0.9, 0.22, 0.2),
	Color(0.95, 0.78, 0.2),
	Color(0.25, 0.5, 1.0),
	Color(0.3, 0.9, 0.42),
	Color(0.82, 0.35, 0.9),
]

const IDLE_ENERGY = 0.12
const SELECTED_ENERGY = 0.7
const LIVE_ENERGY = 1.4

@export var slot : int = 0 : set = _set_slot
@export var is_source : bool = true

var connected = false
var selected = false

var _material

func color():
	return COLORS[slot % COLORS.size()]

func setup():
	_material = StandardMaterial3D.new()
	_material.emission_enabled = true
	$Mesh.material_override = _material
	_paint()

func on_press(agent):
	get_parent().terminal_pressed(self, agent)

func mark(now_connected, now_selected):
	connected = now_connected
	selected = now_selected
	_paint()

func reset_state():
	connected = false
	selected = false
	_paint()

func _set_slot(value):
	slot = value
	_paint()

func _paint():
	if _material == null:
		return
	var energy = IDLE_ENERGY
	if connected:
		energy = LIVE_ENERGY
	elif selected:
		energy = SELECTED_ENERGY
	_material.albedo_color = color()
	_material.emission = color()
	_material.emission_energy_multiplier = energy
