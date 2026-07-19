extends CanvasLayer

@onready var anim: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	TimeLoop.loop_reset.connect(anim.play.bind("Flash"))
	TimeLoop.five_sec_reset.connect(anim.play.bind("Pre"))
