extends Node2D


@onready var talk_zone: Area2D = $TalkArea
var player_in_range = false
var player_ref = null
var king_color = Color("9d54b8")
var dialogue: Dictionary = {
	0: [
		"Hi there fellow slime! What is your name?",
		"... Not much of a talker are you.",
		"Well, Slimey, I have a task for you of important magnitude.",
		"My poor princess has gone off on her own and has not returned home.",
		"I'm starting to worry that she is lost.",
		"Please bring her back to me as soon as possible...",
		"... or be put into prison for failing a request by a king.",
		"Just kidding, but please bring her back."],
	2: ["Oh my sweet princess! Thank goodness!,
		What did I tell you about going out on your own?",
		"Thank you Slimey for bringing her back. As a reward... sorry to say but I don't have much.",
		"Please accept that satisfaction for accomplishing such a mission."]
} 
	



func _ready():
	talk_zone.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	player_ref = body
	if player_ref.dialogue_state == 0 or player_ref.dialogue_state == 2:
		run_dialogue_event()

func run_dialogue_event():
	var camera = get_parent().get_node("MainCamera")
	
	# 1. Freeze Player & Zoom Camera
	player_ref.is_busy = true
	camera.zoom_to(self, 1.5)

	# 2. Start Dialogue
	DialogueManager.start_dialogue(dialogue.get(player_ref.dialogue_state), king_color)
	
	# 3. Wait for finish
	await DialogueManager.dialogue_finished
	
	camera.reset_zoom(player_ref)
	player_ref.is_busy = false
	player_ref.in_dialogue = false
