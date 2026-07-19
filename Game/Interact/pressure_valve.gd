extends Interactable

const NEEDLE_SPEED = 0.05
const NEEDLE_MAX_ANGLE = 1.1
const GREEN_ZONE = 0.25
const HITS_TO_STABILIZE = 3

const ON_COLOR = Color(0.2, 1, 0.3)
const OFF_COLOR = Color(0.12, 0.12, 0.14)

const CLICK_START = 0.03

@onready var needle = $Needle
@onready var lights = $Lights.get_children()
@onready var audio_player: AudioStreamPlayer3D = $AudioPlayer

## Verdadeiro depois que você acertou o bastante, aí o ponteiro para no centro
var is_stabilized = false

## Acertos que você já conseguiu nesse loop
var _good_hits = 0
## Um material por luzinha, pra acender uma de cada vez
var _light_materials = []

func setup():
	for light in lights:
		var material = StandardMaterial3D.new()
		light.material_override = material
		_light_materials.append(material)
	_refresh_lights()

func on_press(_agent):
	if is_stabilized or absf(_needle_offset()) > GREEN_ZONE:
		return
	_good_hits += 1
	audio_player.play(CLICK_START)
	if _good_hits >= HITS_TO_STABILIZE:
		is_stabilized = true
	_refresh_lights()

func is_active():
	return is_stabilized

func reset_state():
	is_stabilized = false
	_good_hits = 0
	_refresh_lights()

func _process(_delta):
	needle.rotation.z = -_needle_offset() * NEEDLE_MAX_ANGLE

func _needle_offset():
	if is_stabilized:
		return 0.0
	return sin(TimeLoop.current_tick * NEEDLE_SPEED)

func _refresh_lights():
	for i in _light_materials.size():
		var lit = i < _good_hits
		_light_materials[i].albedo_color = ON_COLOR if lit else OFF_COLOR
		_light_materials[i].emission_enabled = lit
		_light_materials[i].emission = ON_COLOR
