extends Node3D

@export var turns_per_second : float = 0.7
@export var axis : Vector3 = Vector3.UP

var _rest

func _ready():
	_rest = transform.basis

func _process(_delta):
	var seconds = TimeLoop.current_tick / float(Engine.physics_ticks_per_second)
	transform.basis = Basis(axis.normalized(), seconds * turns_per_second * TAU) * _rest
