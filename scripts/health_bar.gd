extends Control


@onready var bar = $ProgressBar

func set_health(value, max_value):
	bar.max_value = max_value
	bar.value = value
	
