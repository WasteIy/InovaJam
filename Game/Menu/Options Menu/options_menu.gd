extends Control

@onready var resolution_button: OptionButton = $MarginContainer/Panel/MarginContainer/VBoxContainer2/VBoxContainer/ResolutionButton
var possible_resolutions : Dictionary[String, Vector2i] = {
	"1280x720": Vector2i(1280, 720),
	"1600x900": Vector2i(1600, 900),
	"1920x1080": Vector2i(1920, 1080)
}

@onready var fps_button: OptionButton = $MarginContainer/Panel/MarginContainer/VBoxContainer2/VBoxContainer/FPSbutton
var possible_fps : Dictionary[String, int] = {
	"Ilimitado": 0,
	"120": 120,
	"60": 60,
	"30": 30
}

@onready var main_volume_slider: HSlider = $MarginContainer/Panel/MarginContainer/VBoxContainer2/VBoxContainer/MainVolumeBox/MainVolumeSlider
@onready var main_volume_value: Label = $MarginContainer/Panel/MarginContainer/VBoxContainer2/VBoxContainer/MainVolumeBox/MainVolumeValue

@onready var music_slider: HSlider = $MarginContainer/Panel/MarginContainer/VBoxContainer2/VBoxContainer/MusicVolumeBox/MusicSlider
@onready var music_value: Label = $MarginContainer/Panel/MarginContainer/VBoxContainer2/VBoxContainer/MusicVolumeBox/MusicValue

@onready var sfx_slider: HSlider = $MarginContainer/Panel/MarginContainer/VBoxContainer2/VBoxContainer/SfxVolumeBox/SFXSlider
@onready var sfx_value: Label = $MarginContainer/Panel/MarginContainer/VBoxContainer2/VBoxContainer/SfxVolumeBox/SFXValue

@onready var back_button: Button = $MarginContainer/Panel/MarginContainer/VBoxContainer2/BackButton

func _ready() -> void:
	configure_resolution()
	configure_fps()
	resolution_button.item_selected.connect(on_resolution_selected)
	fps_button.item_selected.connect(on_fps_selected)
	back_button.pressed.connect(set_invisible)
	main_volume_slider.value_changed.connect(on_master_sound_update)
	music_slider.value_changed.connect(on_music_sound_update)
	sfx_slider.value_changed.connect(on_sfx_sound_update)

func set_invisible():
	visible = false

func configure_resolution() -> void:
	resolution_button.clear()
	for resolution in possible_resolutions.keys():
		resolution_button.add_item(resolution)

func configure_fps() -> void:
	fps_button.clear()
	for fps in possible_fps.keys():
		fps_button.add_item(fps)

func on_resolution_selected(index: int) -> void:
	var resolution_value_string : String = resolution_button.get_item_text(index)
	var resolution_value = possible_resolutions.get(resolution_value_string, Vector2i(1920, 1080))
	DisplayServer.window_set_size(resolution_value)

func on_fps_selected(index : int) -> void:
	var fps_value_string : String = fps_button.get_item_text(index)
	Engine.max_fps = possible_fps.get(fps_value_string, 0)

func on_master_sound_update(value : float) -> void:
	var new_volume : float = (value / 100.0) * 80 - 80
	AudioServer.set_bus_volume_db(0, new_volume)
	main_volume_value.text = str(int(value)) + "%"

func on_music_sound_update(value : float) -> void:
	var new_volume : float = (value / 100.0) * 80 - 80
	AudioServer.set_bus_volume_db(1, new_volume)
	music_value.text = str(int(value)) + "%"

func on_sfx_sound_update(value : float) -> void:
	var new_volume : float = (value / 100.0) * 80 - 80
	AudioServer.set_bus_volume_db(2, new_volume)
	sfx_value.text = str(int(value)) + "%"

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("Esc"):
		visible = !visible
