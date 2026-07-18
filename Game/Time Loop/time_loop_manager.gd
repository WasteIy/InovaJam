extends Node

signal loop_reset

@export var loop_duration : float = 90.0

var tick = 0
var running = false
var recorder
var clone_scene
var clone_parent
var recordings = []
var clones = []

func configure(parent, scene):
	clone_parent = parent
	clone_scene = scene

func start():
	recordings.clear()
	_clear_clones()
	tick = 0
	running = true
	recorder.reset()

func rewind():
	if not running:
		return
	recordings.append(recorder.frames)
	loop_reset.emit()
	_clear_clones()
	for frames in recordings:
		var clone = clone_scene.instantiate()
		clone_parent.add_child(clone)
		clone.play(frames)
		clones.append(clone)
	recorder.reset()
	tick = 0

func _physics_process(_delta):
	if not running:
		return
	recorder.capture()
	for clone in clones:
		clone.apply(tick)
	tick += 1
	if tick >= loop_duration * Engine.physics_ticks_per_second:
		rewind()

func _clear_clones():
	for clone in clones:
		clone.queue_free()
	clones.clear()
