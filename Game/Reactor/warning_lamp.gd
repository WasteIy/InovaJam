extends MeshInstance3D

const ALARM_COLOR = Color(1, 0.15, 0.1)
const SOLVED_COLOR = Color(0.25, 1, 0.4)

@export var alarm : NodePath
@export var glow_energy : float = 4.0
@export var flash_seconds : float = 0.3
@export var dim_color : Color = Color(0.09, 0.02, 0.02)

var _material
var _alarm
var _last_cycle = -1
var _flash = 0.0

func _ready():
	_material = StandardMaterial3D.new()
	_material.emission_enabled = true
	material_override = _material
	_alarm = get_node_or_null(alarm)
	if _alarm == null:
		_alarm = get_tree().get_first_node_in_group("alarm")
	if _alarm == null:
		push_warning("warning_lamp: sirene nao encontrada, a lampada nao vai piscar")

func _process(delta):
	if Reactor.is_resolved:
		_apply(SOLVED_COLOR, glow_energy)
		return
	if _alarm and _alarm.cycle != _last_cycle:
		_last_cycle = _alarm.cycle
		_flash = 1.0
	_flash = maxf(_flash - delta / flash_seconds, 0.0)
	var shape = _flash * _flash
	_material.albedo_color = dim_color.lerp(ALARM_COLOR, shape)
	_apply_emission(ALARM_COLOR, shape * glow_energy)

func _apply(color, energy):
	_material.albedo_color = color
	_apply_emission(color, energy)

func _apply_emission(color, energy):
	_material.emission = color
	_material.emission_energy_multiplier = energy
