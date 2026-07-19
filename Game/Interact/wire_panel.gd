extends Node3D

@export var wire_thickness : float = 0.012
@onready var audio_player = $AudioPlayer
const WIRE_CONNECT = preload("res://Assets/Sounds/WireConnect.wav")
const ROPE = preload("res://Assets/Sounds/Rope.wav")


var _source_terminals = []
var _held_source = {}
var _joined_wires = {}
var _wire_meshes = {}

func _ready():
	var target_terminals = []
	for child in get_children():
		if child is WireTerminal:
			if child.is_source:
				_source_terminals.append(child)
			else:
				target_terminals.append(child)
	_scramble_wiring(target_terminals)
	TimeLoop.loop_reset.connect(_on_loop_reset)

func is_active():
	return _source_terminals.size() > 0 and _joined_wires.size() >= _source_terminals.size()

func progress():
	if _source_terminals.is_empty():
		return 0.0
	return float(_joined_wires.size()) / float(_source_terminals.size())

func on_terminal_pressed(terminal, agent):
	if terminal.is_wired:
		return
	if terminal.is_source:
		_hold_source(agent, terminal)
		audio_player.stream = ROPE
		audio_player.play()
		return
	if not _held_source.has(agent):
		return
	var source = _held_source[agent]
	if source.wire_id == terminal.wire_id:
		_join_wire(source, terminal)
		audio_player.stream = WIRE_CONNECT
		audio_player.play()
	_hold_source(agent, null)

func _scramble_wiring(target_terminals):
	var wire_ids = []
	for source in _source_terminals:
		wire_ids.append(source.wire_id)
	if target_terminals.size() != wire_ids.size():
		return
	wire_ids.shuffle()
	for i in _source_terminals.size():
		_source_terminals[i].wire_id = wire_ids[i]
	wire_ids.shuffle()
	for i in target_terminals.size():
		target_terminals[i].wire_id = wire_ids[i]

func _hold_source(agent, terminal):
	if _held_source.has(agent):
		var previous = _held_source[agent]
		if is_instance_valid(previous) and not previous.is_wired:
			previous.set_state(false, false)
		_held_source.erase(agent)
	if terminal:
		_held_source[agent] = terminal
		terminal.set_state(false, true)

func _join_wire(source, target):
	_joined_wires[source.wire_id] = true
	source.set_state(true, false)
	target.set_state(true, false)

	var from = source.position
	var to = target.position
	var wire = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(from.distance_to(to), wire_thickness, wire_thickness)
	wire.mesh = box
	var material = StandardMaterial3D.new()
	material.albedo_color = source.wire_color()
	material.emission_enabled = true
	material.emission = source.wire_color()
	material.emission_energy_multiplier = 0.9
	wire.material_override = material
	wire.position = (from + to) * 0.5
	wire.rotation.z = atan2(to.y - from.y, to.x - from.x)
	add_child(wire)
	_wire_meshes[source.wire_id] = wire

func _on_loop_reset():
	_joined_wires.clear()
	_held_source.clear()
	for wire in _wire_meshes.values():
		wire.queue_free()
	_wire_meshes.clear()
