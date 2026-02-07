extends CanvasLayer

@export var player: Player
@export var level: Node2D
@onready var rich_text_label: RichTextLabel = $Control/MarginContainer/RichTextLabel
@onready var anim_player: AnimationPlayer = $ColorRect/AnimationPlayer
@onready var anim_player2: AnimationPlayer = $ColorRect2/AnimationPlayer
@onready var instructions_label: RichTextLabel = $Control/InstructionsLabel
@onready var stage_label: RichTextLabel = $DebugContainer/RichTextLabel
@onready var pause_menu: ColorRect = $PauseMenu
var time_elapsed: float = 0.0
var is_running: bool = true
var DEBUG = false

func _ready() -> void:
	player.level_finished.connect(_stop_timer)
	# 1. Ensure the Rect is actually visible before playing
	$ColorRect2.show() 

	# 2. Match the name exactly (check for underscores vs spaces!)
	anim_player2.play("fade_out")

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

	if DEBUG:
		var stage_string = "Level 1-" + str(level.current_stage)
		stage_label.text = "[font_size=8][color=white]" + stage_string + "[/color][/font_size]"

# Only listen for these keys if the game has ended (timer stopped)
func _input(event: InputEvent) -> void:

	if event.is_action_pressed("enable_debug"):
		toggle_debug()

	if DEBUG:
		if event.is_action_pressed("pause_menu"):
			toggle_menu()

	if is_running:
		return

	if event.is_action_pressed("ui_restart"):
		get_tree().reload_current_scene()
		
	if event.is_action_pressed("ui_quit"):
		get_tree().quit()

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
	var raw_time = rich_text_label.get_parsed_text()
	
	# 2. Apply the new big styling
	rich_text_label.text = "[center][font_size=48][color=white]" + raw_time + "[/color][/font_size][/center]"
	instructions_label.show()

func toggle_menu() -> void:
	if pause_menu.visible:
		pause_menu.visible = false
	else:
		pause_menu.visible = true

func toggle_debug() -> void:
	DEBUG = !DEBUG

	if DEBUG:
		stage_label.show()
	else:
		stage_label.hide()
