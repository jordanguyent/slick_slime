extends CanvasLayer

signal dialogue_finished
@onready var text_label = $DialogueUI/Background/MarginContainer/SpeechText
@onready var background_color = $DialogueUI/Background
var lines: Array = []
var is_typing: bool = false
var current_tween: Tween

var king_sound = preload("res://sounds/sfx/blip2.wav")
var princess_sound = preload("res://sounds/sfx/blip2.wav")
var speaking: String

func _ready():
	hide()

func start_dialogue(dialogue_lines: Array, theme_color: Color = Color.WHITE, speaker: String = ""):
	lines = dialogue_lines.duplicate()
	speaking = speaker
	background_color.self_modulate = theme_color
	
	show()
	next_line()

func next_line():
	# If we are currently typing, skip to the end of the line
	if is_typing:
		finish_current_line()
		return

	if lines.size() > 0:
		display_text(lines.pop_front())
	else:
		hide()
		dialogue_finished.emit()

func _input(event):
	if event.is_action_pressed("player_grapple") or event.is_action_pressed("player_jump") or event.is_action_pressed("interact"):
		if visible:
			next_line()

func set_visible_characters(amount: int):
	if amount > text_label.visible_characters:
		text_label.visible_characters = amount
		if speaking == "Princess":
			if amount % 4 == 0:
				var pitch = randf_range(0.8, 1.1) 
				AudioLoader.play_sfx(princess_sound, "Master", true, -16, pitch)
		else:
			if amount % 4 == 0: 
				var pitch = randf_range(0.1, 0.3) 
				AudioLoader.play_sfx(king_sound, "Master", true, -16, pitch)
			
			
			

func display_text(full_text: String):
	is_typing = true
	text_label.text = full_text

	# Start at 0% visible
	text_label.visible_ratio = 0.0

	# Calculate speed: roughly 0.03 seconds per character
	var duration = full_text.length() * 0.03

	# Create the animation
	current_tween = create_tween()
	current_tween.tween_method(set_visible_characters, 0, full_text.length(), duration)

	# Reset typing flag when finished
	current_tween.finished.connect(func(): is_typing = false)

func finish_current_line():
	# Instantly show the whole line if the player clicks 'E' while it's typing
	if current_tween:
		current_tween.kill()
	text_label.visible_characters = -1
	is_typing = false