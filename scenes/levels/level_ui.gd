extends CanvasLayer

@onready var rich_text_label: RichTextLabel = $Control/MarginContainer/RichTextLabel
@onready var slime_bar: ProgressBar = $Control/MarginContainer2/ProgressBar
@export var player: CharacterBody2D

var time_elapsed: float = 0.0

func _process(delta: float):
	time_elapsed += delta
	
	var minutes := int(time_elapsed / 60)
	var seconds := int(time_elapsed) % 60
	
	# fmod(time_elapsed, 1) gets the decimal part (e.g., 0.543)
	# Multiplying by 100 gives you 2 digits of milliseconds
	var msecs := fmod(time_elapsed, 1) * 100
	
	# Format the string
	# %d is an integer
	# %02d is a 2-digit integer with a leading zero
	var time_string = "%d:%02d.%02d" % [minutes, seconds, msecs]
	
	# Update the RichTextLabel
	rich_text_label.text = "[font_size=8][color=white]" + time_string + "[/color][/font_size]"

	if not is_equal_approx(slime_bar.value, player.slime_resource):
		slime_bar.value = player.slime_resource
