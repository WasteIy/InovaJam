class_name TvScene
extends Label

@export var time_value: int:
	set(value):
		var minutes : int = int(value / 60)
		var seconds : int = value % 60
		var seconds_text : String
		if seconds < 10:
			seconds_text = "0" + str(seconds)
		else:
			seconds_text = str(seconds)
		text = "0" + str(minutes) + ":" + seconds_text
