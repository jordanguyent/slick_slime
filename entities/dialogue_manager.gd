extends CanvasLayer

signal dialogue_finished
@onready var text_label = $DialogueUI/Background/MarginContainer/SpeechText
@onready var background_color = $DialogueUI/Background
var lines: Array = []
var is_typing: bool = false
var current_tween: Tween

func _ready():
	hide()

func start_dialogue(dialogue_lines: Array, theme_color: Color = Color.WHITE):
	lines = dialogue_lines.duplicate()

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

func display_text(full_text: String):
	is_typing = true
	text_label.text = full_text

	# Start at 0% visible
	text_label.visible_ratio = 0.0

	# Calculate speed: roughly 0.03 seconds per character
	var duration = full_text.length() * 0.03

	# Create the animation
	current_tween = create_tween()
	current_tween.tween_property(text_label, "visible_ratio", 1.0, duration)

	# Reset typing flag when finished
	current_tween.finished.connect(func(): is_typing = false)

func finish_current_line():
	# Instantly show the whole line if the player clicks 'E' while it's typing
	if current_tween:
		current_tween.kill()
	text_label.visible_ratio = 1.0
	is_typing = false