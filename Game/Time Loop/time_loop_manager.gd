extends Node

## Dispara logo antes de um loop novo começar, pros puzzles se limparem
signal loop_reset
signal five_sec_reset
var emitted_five_sec = false

## Quanto tempo você tem antes do loop voltar sozinho
@export var loop_duration_seconds : float = 15.0

## Ticks de física desde que esse loop começou. Gravação e replay se guiam por isso
var current_tick = 0
## Fica falso até chamarem start_run(), pra  gravar nada antes da run começar
var is_running = false
## O player atual
var player_recorder
## Cena do clone, instanciada uma vez por loop passado
var clone_scene
## Quem vira pai dos clones, atualmente a raiz do nível
var clone_container
## Uma entrada por loop terminado, cada uma com a lista de frames de cada tick
var past_recordings = []
## Clones refazendo as runs antigas agora
var active_clones = []

func setup_clones(container, scene):
	clone_container = container
	clone_scene = scene

func start_run():
	past_recordings.clear()
	_despawn_clones()
	current_tick = 0
	is_running = true
	player_recorder.reset_to_spawn()

func rewind_loop():
	if not is_running:
		return
	emitted_five_sec = false
	past_recordings.append(player_recorder.recorded_frames)
	loop_reset.emit()
	_despawn_clones()
	for frames in past_recordings:
		var clone = clone_scene.instantiate()
		clone_container.add_child(clone)
		clone.load_recording(frames)
		active_clones.append(clone)
	for key in get_tree().get_nodes_in_group("keys"):
		if key.is_temporal and key.run_index >= 0 and key.run_index < active_clones.size():
			key.give_to(active_clones[key.run_index])
	player_recorder.reset_to_spawn()
	current_tick = 0

func _physics_process(_delta):
	if not is_running:
		return
	player_recorder.capture_frame()
	for clone in active_clones:
		clone.replay_tick(current_tick)
	current_tick += 1
	if current_tick >= (loop_duration_seconds - 5) * Engine.physics_ticks_per_second:
		if not emitted_five_sec: 
			five_sec_reset.emit()
			emitted_five_sec = true
	if current_tick >= loop_duration_seconds * Engine.physics_ticks_per_second:
		rewind_loop()

func _despawn_clones():
	for clone in active_clones:
		clone.queue_free()
	active_clones.clear()
