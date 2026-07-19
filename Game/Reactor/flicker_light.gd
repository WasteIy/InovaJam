extends Light3D

@export var flicker_amount : float = 0.3
@export var flicker_speed : float = 0.9
@export var blink_speed : float = 0.28
@export var blink_threshold : float = -0.42
@export var blink_depth : float = 0.06

var _noise = FastNoiseLite.new()
var _base_energy = 1.0

func _ready():
	_base_energy = light_energy
	_noise.seed = randi()
	_noise.frequency = 1.0

func _process(_delta):
	var tick = TimeLoop.current_tick
	var buzz = _noise.get_noise_1d(tick * flicker_speed)
	var energy = _base_energy * (1.0 + buzz * flicker_amount)
	if _noise.get_noise_1d(tick * blink_speed + 300.0) < blink_threshold:
		energy *= blink_depth
	light_energy = maxf(energy, 0.0)
