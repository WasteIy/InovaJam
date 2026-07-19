extends AudioStreamPlayer3D

@export var start_gap : float = 0.7
@export var end_gap : float = -0.55
@export var gap_accel : float = 0.8
@export var min_interval : float = 0.2

@export var start_volume : float = -9.0
@export var end_volume : float = 1.0

@export var pitch_drift : float = 0.06
@export var volume_drift : float = 2.5
@export var gap_drift : float = 0.25

var _noise = FastNoiseLite.new()
var _wait = 0.0
var _cycle = 0

func _ready():
	_noise.seed = randi()
	_noise.frequency = 1.0

func _process(delta):
	if Reactor.is_resolved:
		return
	_wait -= delta
	if _wait > 0.0:
		return
	_cycle += 1
	var heat = pow(_progress(), gap_accel)
	pitch_scale = 1.0 + _noise.get_noise_1d(_cycle * 1.7) * pitch_drift
	volume_db = lerpf(start_volume, end_volume, heat) + _noise.get_noise_1d(_cycle * 2.3 + 100.0) * volume_drift
	play()
	var gap = lerpf(start_gap, end_gap, heat)
	gap *= 1.0 + _noise.get_noise_1d(_cycle * 3.1 + 200.0) * gap_drift
	_wait = maxf(stream.get_length() / pitch_scale + gap, min_interval)

func _progress():
	var span = TimeLoop.loop_duration_seconds * Engine.physics_ticks_per_second
	return clampf(TimeLoop.current_tick / span, 0.0, 1.0)
