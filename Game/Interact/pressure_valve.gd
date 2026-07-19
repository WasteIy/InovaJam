extends Interactable

const NEEDLE_SPEED = 0.05
const NEEDLE_MAX_ANGLE = PI
const HITS_TO_STABILIZE = 3

const SETTLED_SHAKE = 0.35
const SETTLED_SPEED = 0.55
const SETTLE_SECONDS = 0.6

@export var wander : float = 4.0
@export var wander_scale : float = 0.02
@export var jitter : float = 0.1
@export var jitter_scale : float = 0.4

@export var calm_chaos : float = 0.12
@export var chaos_starts_at : float = 0.35
@export var speed_spread : float = 0.18

const SECTOR = PI / 2
const SECTOR_STEP = PI / 4
const SECTOR_STEPS = 8
const DEFAULT_CENTER = PI / 4

const ON_COLOR = Color(0.2, 1, 0.3)
const OFF_COLOR = Color(0.12, 0.12, 0.14)

const CLICK_START = 0.03

@onready var needle = $Needle
@onready var zone = $Zone
@onready var lights = $Lights.get_children()
@onready var audio_player: AudioStreamPlayer3D = $AudioPlayer

var is_stabilized = false

var _good_hits = 0
var _light_materials = []
var _settle = 0.0
var _zone_center = DEFAULT_CENTER
var _zone_rest
var _noise = FastNoiseLite.new()
var _speed_scale = 1.0
var _phase_offset = 0.0

func setup():
	for light in lights:
		var material = StandardMaterial3D.new()
		light.material_override = material
		_light_materials.append(material)
	_noise.seed = randi()
	_noise.frequency = 1.0
	_speed_scale = randf_range(1.0 - speed_spread, 1.0 + speed_spread)
	_phase_offset = randf_range(0.0, TAU)
	_zone_rest = zone.transform
	_place_zone()
	_refresh_lights()

func _place_zone():
	_zone_center = DEFAULT_CENTER + (randi() % SECTOR_STEPS) * SECTOR_STEP
	var spin = Basis(Vector3.BACK, _zone_center - DEFAULT_CENTER)
	zone.transform = Transform3D(spin * _zone_rest.basis, spin * _zone_rest.origin)

func on_press(_agent):
	if is_stabilized:
		return
	if absf(wrapf(_needle_angle() - _zone_center, -PI, PI)) > SECTOR * 0.5:
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
	_settle = 0.0
	_good_hits = 0
	_refresh_lights()

func _process(delta):
	if is_stabilized:
		_settle = minf(_settle + delta / SETTLE_SECONDS, 1.0)
	needle.rotation.z = _needle_angle()

func _chaos():
	if Reactor.is_resolved:
		return calm_chaos
	var span = TimeLoop.loop_duration_seconds * Engine.physics_ticks_per_second
	var elapsed = TimeLoop.current_tick / span
	var ramp = clampf(inverse_lerp(chaos_starts_at, 1.0, elapsed), 0.0, 1.0)
	return lerpf(calm_chaos, 1.0, ramp * ramp)

func _sweep_angle():
	var tick = TimeLoop.current_tick
	var chaos = _chaos()
	var drift = _noise.get_noise_1d(tick * wander_scale) * wander * chaos
	var shiver = _noise.get_noise_1d(tick * jitter_scale + 500.0) * jitter * chaos
	return sin(tick * NEEDLE_SPEED * _speed_scale + _phase_offset + drift) * NEEDLE_MAX_ANGLE + shiver

func _needle_angle():
	var sweep = _sweep_angle()
	if not is_stabilized:
		return sweep
	var t = TimeLoop.current_tick * SETTLED_SPEED
	var wobble = sin(t) * 0.6 + sin(t * 2.3) * 0.4
	var settled = _zone_center + wobble * SECTOR * 0.5 * SETTLED_SHAKE
	return lerp_angle(sweep, settled, smoothstep(0.0, 1.0, _settle))

func _refresh_lights():
	for i in _light_materials.size():
		var lit = i < _good_hits
		_light_materials[i].albedo_color = ON_COLOR if lit else OFF_COLOR
		_light_materials[i].emission_enabled = lit
		_light_materials[i].emission = ON_COLOR
