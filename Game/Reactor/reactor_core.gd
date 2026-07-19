extends Node3D

@export var calm_intensity : float = 0.08
@export var active_intensity : float = 0.45
@export var critical_intensity : float = 1.0

@export var max_lift : float = 2.0
@export var max_speed : float = 3.5
@export var max_chaos : float = 1.5
@export var calm_detail : float = 3.0
@export var critical_detail : float = 14.0

@export var octaves : int = 4
@export var blend_seconds : float = 2.0

var _cubes = []
var _rest = []
var _point = []
var _min = Vector2.ZERO
var _size = Vector2.ONE
var _noise = FastNoiseLite.new()
var _time = 0.0
var _jitter_time = 0.0
var _intensity = 0.0

func _ready():
	_noise.frequency = 1.0
	_noise.fractal_octaves = octaves
	_noise.fractal_lacunarity = 2.5
	_noise.fractal_gain = 0.6
	_collect(self)
	_measure()
	_intensity = calm_intensity

func _process(delta):
	var weight = clampf(delta / blend_seconds, 0.0, 1.0)
	_intensity = lerpf(_intensity, _target_intensity(), weight)
	var lift = max_lift * _intensity
	var detail = lerpf(calm_detail, critical_detail, _intensity)
	var chaos = max_chaos * _intensity * _intensity
	_time += delta * max_speed * _intensity
	_jitter_time += delta * max_speed * 4.0 * _intensity
	for i in _cubes.size():
		var u = (_point[i].x - _min.x) / _size.x
		var v = (_point[i].y - _min.y) / _size.y
		var wave = _noise.get_noise_3d(u * detail, _time, v * detail)
		var jitter = _noise.get_noise_3d(u * 90.0 + 500.0, _jitter_time, v * 90.0 + 500.0)
		var moved = _rest[i]
		moved.origin.y = _rest[i].origin.y + (wave + jitter * chaos) * lift
		_cubes[i].transform = moved

func _target_intensity():
	if Reactor.current_phase == Reactor.Phase.CRITICAL:
		return critical_intensity
	if Reactor.current_phase == Reactor.Phase.ACTIVE:
		return active_intensity
	return calm_intensity

func _measure():
	var min_x = INF
	var min_z = INF
	var max_x = -INF
	var max_z = -INF
	for p in _point:
		min_x = minf(min_x, p.x)
		max_x = maxf(max_x, p.x)
		min_z = minf(min_z, p.y)
		max_z = maxf(max_z, p.y)
	_min = Vector2(min_x, min_z)
	_size = Vector2(maxf(max_x - min_x, 0.001), maxf(max_z - min_z, 0.001))

func _collect(node):
	for child in node.get_children():
		if child is MeshInstance3D:
			_cubes.append(child)
			_rest.append(child.transform)
			var center = child.transform * child.mesh.get_aabb().get_center()
			_point.append(Vector2(center.x, center.z))
		_collect(child)
