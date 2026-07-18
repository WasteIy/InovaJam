extends Control

@onready var start_button: Button = $VBoxContainer/VBoxContainer/StartGame_button
@onready var options_button: Button = $VBoxContainer/VBoxContainer/Options_button
@onready var quit_button: Button = $VBoxContainer/VBoxContainer/Quit_button
@onready var options_menu: Control = $"../OptionsMenu"

func _ready() -> void:
	start_button.pressed.connect(start_pressed)
	options_button.pressed.connect(options_pressed)
	quit_button.pressed.connect(quit_pressed)

func start_pressed():
	pass

func options_pressed():
	options_menu.visible = true

func quit_pressed():
	get_tree().quit()
