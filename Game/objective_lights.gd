extends Node3D

const OFF_COLOR = Color(0.02, 0.02, 0.025)
const ERROR_COLOR = Color(1, 0.15, 0.1)
const SOLVED_COLOR = Color(0.25, 1, 0.4)

@export var objectives : NodePath
@export var lit_energy : float = 1.8

var _lamps = []
var _goals = []
var _solved = []

func _ready():
	for lamp in get_children():
		lamp.material_override = _make_material(OFF_COLOR, false)
	var root = _find_objectives()
	if root == null:
		push_warning("objective_lights: nenhum no Objectives encontrado")
		return
	var picked = get_children()
	picked.shuffle()
	for child in root.get_children():
		if child.is_in_group("keys"):
			continue
		if _goals.size() >= picked.size():
			break
		_goals.append(child)
		_lamps.append(picked[_goals.size() - 1])
		_solved.append(false)
	for i in _lamps.size():
		_lamps[i].material_override = _make_material(ERROR_COLOR, true)

func _find_objectives():
	var root = get_node_or_null(objectives)
	if root:
		return root
	return get_parent().get_node_or_null("Objectives")

func _process(_delta):
	for i in _goals.size():
		var solved = _goals[i].is_active()
		if solved == _solved[i]:
			continue
		_solved[i] = solved
		var material = _lamps[i].material_override
		var color = SOLVED_COLOR if solved else ERROR_COLOR
		material.albedo_color = color
		material.emission = color

func _make_material(color, lit):
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = lit
	material.emission = color
	material.emission_energy_multiplier = lit_energy
	return material
