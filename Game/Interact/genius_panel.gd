extends Node3D

enum { SHOWING, LISTENING, ROUND_DONE, FAILED, SOLVED }

const VOICES = 4

const TONE = preload("res://Assets/Sounds/genius_sound.wav")
const WRONG = preload("res://Assets/Sounds/genius_wrong.wav")

@export var sequence_length : int = 4
@export var flash_ticks : int = 26
@export var gap_ticks : int = 14
@export var start_delay_ticks : int = 36
@export var idle_replay_ticks : int = 120
@export var press_flash_ticks : int = 10
@export var error_ticks : int = 42
@export var error_blink_ticks : int = 7
@export var solved_beeps : int = 3
@export var beep_gap_ticks : int = 8
@export var beep_pitch : float = 2.4

var _buttons = []
var _sequence = []
var _state = SHOWING
var _round = 1
var _input_index = 0
var _revealed = 0
var _phase_tick = 0
var _lit_button
var _flash_ticks_left = 0
var _blinking_error = false
var _beeps_left = 0
var _beep_tick = 0

@onready var audio_player = $AudioPlayer

var _voices = []
var _next_voice = 0


func _ready():
	for child in get_children():
		if child is GeniusButton:
			_buttons.append(child)
	for i in sequence_length:
		_sequence.append(_buttons[randi() % _buttons.size()])
	_voices.append(audio_player)
	for i in VOICES - 1:
		var voice = audio_player.duplicate()
		add_child(voice)
		_voices.append(voice)
	TimeLoop.loop_reset.connect(_on_loop_reset)

func _next_free_voice():
	var voice = _voices[_next_voice]
	_next_voice = (_next_voice + 1) % _voices.size()
	return voice

func _play_tone(index):
	var voice = _next_free_voice()
	voice.stream = TONE
	voice.pitch_scale = 0.8 + 0.1 * index
	voice.play()

func _play_beep():
	var voice = _next_free_voice()
	voice.stream = TONE
	voice.pitch_scale = beep_pitch
	voice.play()

func _play_wrong():
	var voice = _next_free_voice()
	voice.stream = WRONG
	voice.pitch_scale = 1.0
	voice.play()

func is_active():
	return _state == SOLVED

func progress():
	return float(_round - 1) / float(sequence_length)

func on_button_pressed(button, _agent):
	if _state == FAILED or _state == SOLVED or _state == ROUND_DONE:
		return
	if _input_index >= _revealed or button != _sequence[_input_index]:
		_fail()
		return
	_input_index += 1
	_play_tone(_input_index)
	if _state == LISTENING:
		_light(button)
		_flash_ticks_left = press_flash_ticks
		_phase_tick = 0
	if _input_index < _round:
		return
	_round += 1
	if _round > sequence_length:
		_state = SOLVED
		_set_all_solved(true)
		_beeps_left = solved_beeps
		_beep_tick = 0
		return
	_input_index = 0
	_state = ROUND_DONE
	_phase_tick = 0

func _physics_process(_delta):
	_phase_tick += 1
	if _beeps_left > 0:
		_beep_tick -= 1
		if _beep_tick <= 0:
			_play_beep()
			_beeps_left -= 1
			_beep_tick = beep_gap_ticks
	match _state:
		SHOWING:
			_update_showing()
		LISTENING:
			_update_listening()
		ROUND_DONE:
			_update_round_done()
		FAILED:
			_update_failed()

func _update_showing():
	var elapsed = _phase_tick - start_delay_ticks
	if elapsed < 0:
		return
	var step = flash_ticks + gap_ticks
	var index = elapsed / step
	if index >= _round:
		_state = LISTENING
		_revealed = _round
		_phase_tick = 0
		_light(null)
		return
	if elapsed % step < flash_ticks:
		_revealed = index + 1
		_light(_sequence[index])
		#audio_player.pitch_scale = 0.8 + 0.1 * index
		#audio_player.play()
	else:
		_light(null)

func _update_listening():
	if _flash_ticks_left > 0:
		_flash_ticks_left -= 1
		if _flash_ticks_left == 0:
			_light(null)
		return
	if _input_index == 0 and _phase_tick >= idle_replay_ticks:
		_start_showing()

func _fail():
	_light(null)
	_state = FAILED
	_phase_tick = 0
	_set_all_error(true)
	_play_wrong()

func _update_round_done():
	if _phase_tick >= press_flash_ticks:
		_start_showing()

func _update_failed():
	if _phase_tick >= error_ticks:
		_set_all_error(false)
		_round = 1
		_start_showing()
		return
	_set_all_error((_phase_tick / error_blink_ticks) % 2 == 0)

func _start_showing():
	_state = SHOWING
	_input_index = 0
	_revealed = 0
	_phase_tick = 0
	_flash_ticks_left = 0
	_light(null)

func _light(button):
	if _lit_button == button:
		return
	if _lit_button:
		_lit_button.set_lit(false)
	_lit_button = button
	if button:
		button.set_lit(true)

func _set_all_error(failed):
	if _blinking_error == failed:
		return
	_blinking_error = failed
	for button in _buttons:
		button.set_error(failed)

func _set_all_solved(solved):
	for button in _buttons:
		button.set_solved(solved)

func _on_loop_reset():
	_beeps_left = 0
	_lit_button = null
	_blinking_error = false
	_round = 1
	_start_showing()
