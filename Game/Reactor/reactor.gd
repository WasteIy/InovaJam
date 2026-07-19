extends Node

signal phase_changed(phase)

enum Phase { CALM, ACTIVE, CRITICAL }

@export var active_starts_at : float = 0.35
@export var critical_starts_at : float = 0.7

var current_phase = Phase.CALM
var is_resolved = false


func resolve():
	is_resolved = true
	current_phase = Phase.CALM
	phase_changed.emit(current_phase)

func _physics_process(_delta):
	if is_resolved:
		return
	var phase = _phase_from_time()
	if phase == current_phase:
		return
	current_phase = phase
	phase_changed.emit(phase)

func _phase_from_time():
	var elapsed = TimeLoop.current_tick / (TimeLoop.loop_duration_seconds * Engine.physics_ticks_per_second)
	if elapsed >= critical_starts_at:
		return Phase.CRITICAL
	if elapsed >= active_starts_at:
		return Phase.ACTIVE
	return Phase.CALM
