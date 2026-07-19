extends Node

signal phase_changed(phase)

enum Phase { CALM, ACTIVE, CRITICAL }

@export var active_starts_at : float = 0.35
@export var critical_starts_at : float = 0.7

var current_phase = Phase.CALM

var _debug_offset = 0

func _unhandled_input(event):
	if event.is_action_pressed("debug_next_phase"):
		_debug_offset = clampi(_debug_offset + 1, -2, 2)
	if event.is_action_pressed("debug_prev_phase"):
		_debug_offset = clampi(_debug_offset - 1, -2, 2)

func _physics_process(_delta):
	var phase = clampi(_phase_from_time() + _debug_offset, Phase.CALM, Phase.CRITICAL)
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
