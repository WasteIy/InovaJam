extends Node3D

@export var calm_shake : float = 0.0
@export var active_shake : float = 0.0
@export var critical_shake : float = 1.0

@export var shift_amount : float = 0.03
@export var tilt_amount : float = 0.05
@export var frequency : float = 12.0
@export var blend_seconds : float = 1.5

var _noise = FastNoiseLite.new()
var _rest
var _time = 0.0
var _shake = 0.0

func _ready():
	_noise.frequency = 1.0
	_noise.seed = randi()
	_rest = transform
	var node = self
	if node is RigidBody3D:
		node.freeze = true

func _process(delta):
	var weight = clampf(delta / blend_seconds, 0.0, 1.0)
	_shake = lerpf(_shake, _target_shake(), weight)
	_time += delta * frequency
	var shift = Vector3(
		_noise.get_noise_2d(_time, 0.0),
		_noise.get_noise_2d(_time, 100.0),
		_noise.get_noise_2d(_time, 200.0)
	) * shift_amount * _shake
	var tilt = Vector3(
		_noise.get_noise_2d(_time, 300.0),
		_noise.get_noise_2d(_time, 400.0),
		_noise.get_noise_2d(_time, 500.0)
	) * tilt_amount * _shake
	var shaken = _rest
	shaken.origin = _rest.origin + shift
	shaken.basis = _rest.basis.rotated(Vector3.RIGHT, tilt.x).rotated(Vector3.UP, tilt.y).rotated(Vector3.FORWARD, tilt.z)
	transform = shaken

func _target_shake():
	if Reactor.is_resolved:
		return 0.0
	if Reactor.current_phase == Reactor.Phase.CRITICAL:
		return critical_shake
	if Reactor.current_phase == Reactor.Phase.ACTIVE:
		return active_shake
	return calm_shake
