extends Camera3D

@export var calm_shake : float = 0.0
@export var active_shake : float = 0.04
@export var critical_shake : float = 0.15

@export var shift_amount : float = 0.06
@export var tilt_amount : float = 0.015
@export var frequency : float = 14.0
@export var blend_seconds : float = 1.5

var _noise = FastNoiseLite.new()
var _time = 0.0
var _shake = 0.0

func _ready():
	_noise.frequency = 1.0

func _process(delta):
	var weight = clampf(delta / blend_seconds, 0.0, 1.0)
	_shake = lerpf(_shake, _target_shake(), weight)
	_time += delta * frequency
	position = Vector3(
		_noise.get_noise_2d(_time, 0.0),
		_noise.get_noise_2d(_time, 100.0),
		_noise.get_noise_2d(_time, 200.0)
	) * shift_amount * _shake
	rotation = Vector3(
		_noise.get_noise_2d(_time, 300.0),
		_noise.get_noise_2d(_time, 400.0),
		_noise.get_noise_2d(_time, 500.0)
	) * tilt_amount * _shake

func _target_shake():
	if Reactor.current_phase == Reactor.Phase.CRITICAL:
		return critical_shake
	if Reactor.current_phase == Reactor.Phase.ACTIVE:
		return active_shake
	return calm_shake
