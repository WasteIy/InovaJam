extends Node3D

@export var wire_thickness : float = 0.05

var _sources = []
var _selected = {}
var _links = {}
var _wires = {}

func _ready():
	var targets = []
	for child in get_children():
		if child is WireTerminal:
			if child.is_source:
				_sources.append(child)
			else:
				targets.append(child)
	_scramble(targets)
	TimeLoop.loop_reset.connect(_on_loop_reset)

func _scramble(targets):
	var slots = []
	for source in _sources:
		slots.append(source.slot)
	if targets.size() != slots.size():
		push_warning("%s: %d fontes para %d destinos, a fiacao nao fecha" % [name, slots.size(), targets.size()])
		return
	slots.shuffle()
	for i in _sources.size():
		_sources[i].slot = slots[i]
	slots.shuffle()
	for i in targets.size():
		targets[i].slot = slots[i]

func is_active():
	return _sources.size() > 0 and _links.size() >= _sources.size()

func progress():
	if _sources.is_empty():
		return 0.0
	return float(_links.size()) / float(_sources.size())

func terminal_pressed(terminal, agent):
	if terminal.connected:
		return
	if terminal.is_source:
		_select(agent, terminal)
		return
	if not _selected.has(agent):
		return
	var source = _selected[agent]
	if source.slot == terminal.slot:
		_link(source, terminal)
	_select(agent, null)

func _select(agent, terminal):
	if _selected.has(agent):
		var previous = _selected[agent]
		if is_instance_valid(previous) and not previous.connected:
			previous.mark(false, false)
		_selected.erase(agent)
	if terminal:
		_selected[agent] = terminal
		terminal.mark(false, true)

func _link(source, target):
	_links[source.slot] = target.slot
	source.mark(true, false)
	target.mark(true, false)

	var from = source.position
	var to = target.position
	var wire = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(from.distance_to(to), wire_thickness, wire_thickness)
	wire.mesh = box
	var material = StandardMaterial3D.new()
	material.albedo_color = source.color()
	material.emission_enabled = true
	material.emission = source.color()
	material.emission_energy_multiplier = 0.9
	wire.material_override = material
	wire.position = (from + to) * 0.5
	wire.rotation.z = atan2(to.y - from.y, to.x - from.x)
	add_child(wire)
	_wires[source.slot] = wire

func _on_loop_reset():
	_links.clear()
	_selected.clear()
	for wire in _wires.values():
		wire.queue_free()
	_wires.clear()
