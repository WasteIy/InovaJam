class_name GeniusButton
extends Interactable

const IDLE_ENERGY = 0.1
const LIT_ENERGY = 1.6
const ERROR_COLOR = Color(1, 0.15, 0.1)
const SOLVED_COLOR = Color(0.25, 1, 0.4)
const PRESS_DEPTH = 0.09
const PRESS_RECOVER = 7.0

@export var button_color : Color = Color(0.9, 0.25, 0.22)

@onready var mesh = $Mesh

var is_lit = false
var is_error = false
var is_solved = false

var _material
var _press_amount = 0.0

func setup():
	_material = StandardMaterial3D.new()
	_material.emission_enabled = true
	mesh.material_override = _material
	_refresh_glow()

func on_press(agent):
	_press_amount = 1.0
	get_parent().on_button_pressed(self, agent)

func set_lit(lit):
	is_lit = lit
	_refresh_glow()

func set_error(failed):
	is_error = failed
	_refresh_glow()

func set_solved(solved):
	is_solved = solved
	_refresh_glow()

func reset_state():
	is_lit = false
	is_error = false
	is_solved = false
	_press_amount = 0.0
	mesh.position.z = 0.0
	_refresh_glow()

func _process(delta):
	if _press_amount <= 0.0:
		return
	_press_amount = maxf(_press_amount - PRESS_RECOVER * delta, 0.0)
	mesh.position.z = -PRESS_DEPTH * _press_amount

func _refresh_glow():
	if _material == null:
		return
	var color = button_color
	if is_error:
		color = ERROR_COLOR
	elif is_solved:
		color = SOLVED_COLOR
	_material.albedo_color = color
	_material.emission = color
	_material.emission_energy_multiplier = LIT_ENERGY if is_lit or is_error or is_solved else IDLE_ENERGY
