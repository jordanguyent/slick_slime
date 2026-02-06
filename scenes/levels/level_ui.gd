extends CanvasLayer

@export var player: Player
@onready var rich_text_label: RichTextLabel = $Control/MarginContainer/RichTextLabel
@onready var anim_player: AnimationPlayer = $ColorRect/AnimationPlayer
@onready var anim_player2: AnimationPlayer = $ColorRect2/AnimationPlayer
var time_elapsed: float = 0.0
var is_running: bool = true

func _ready() -> void:
	player.level_finished.connect(_stop_timer)

func _process(delta: float):
	if not is_running:
		return

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

func _stop_timer():
	is_running = false
	show_final_screen()

func play_exit_transition():
	anim_player.play("slide_in")
	await anim_player.animation_finished

func play_enter_transition():
	anim_player.play("slide_out")
	await anim_player.animation_finished

func show_final_screen() -> void:
	anim_player2.play("fade in")
	rich_text_label.text = "[center][font_size=24]" + rich_text_label.text + "[/font_size][/center]"

	# var screen_size = get_viewport().get_visible_rect().size
	# $Control/MarginContainer.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_KEEP_SIZE)
