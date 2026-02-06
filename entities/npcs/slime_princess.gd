extends Node2D


@export var follow_speed: float = 150.0
@export var stop_distance: float = 60.0 

var velocity: Vector2 = Vector2.ZERO

# Adjust these to your liking
@export var friction: float = 0.92  # Lower is a faster stop (0.8), higher is "ice skating" (0.98)
@export var acceleration: float = 20.0

var is_following: bool = false
@onready var prompt = $Prompt
@onready var anim_player = $AnimationPlayer
var player_in_range = false
var player_ref = null
var princess_color = Color(1.0, 0.7, 0.8)
var dialogue = [
		"Oh! You scared me! Who are you?",
		"What are you doing out here this far into the woods?",
		"Not much a talker huh... Nice to meet you... Slicky, that's what I'll call you.",
		"I figured I'd get some fresh air, since my dad doesn't often let me go outside our home.",
		"He's worries way too much.",
		"I suppose that's what dads do.",
		"But here I am...",
		"...",
		"I'm lost...",
		"Please help me find my home!",
		"What's that? You can bring me home?",
		"Great! Not like I gave you much of a choice, haha.",
		"Good news for you, I can fly alongside you, so don't worry about me being a hinderance."
	]

var talked_to: bool = false

func _ready():
	prompt.hide()
	anim_player.play("IdleBack")
	$TalkArea.body_entered.connect(_on_body_entered)
	$TalkArea.body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	player_ref = body
	if player_ref.dialogue_state == 1:
		player_in_range = true
		prompt.show()

func _on_body_exited(body):
	if body is Player:
		player_in_range = false
		prompt.hide()

func _input(event):
	if player_in_range and not talked_to and event.is_action_pressed("interact"):
		talked_to = true
		run_dialogue_event()

func run_dialogue_event():
	var camera = get_parent().get_node("MainCamera")
	
	# 1. Freeze Player & Zoom Camera
	player_ref.is_busy = true
	camera.zoom_to(self, 1.5)
	prompt.hide()

	await play_cinematic_jump()

	# 2. Start Dialogue
	DialogueManager.start_dialogue(dialogue, princess_color)
	
	# 3. Wait for finish
	await DialogueManager.dialogue_finished
	
	# 4. Reset
	prompt.hide()
	camera.reset_zoom(player_ref)
	player_ref.is_busy = false
	is_following = true
	player_ref.in_dialogue = false

func play_cinematic_jump():
	var start_y = global_position.y # Save the exact floor position
	anim_player.play("Jump") 

	await anim_player.animation_finished

	# FORCE RESET: Ensure any floating decimals or animation offsets are cleared
	global_position.y = start_y 
	anim_player.play("IdleFront")

func _process(delta: float) -> void:
	if is_following and player_ref:
		move_towards_player(delta)

func move_towards_player(delta: float):
	var target_pos = player_ref.global_position
	var current_pos = global_position
	var distance = current_pos.distance_to(target_pos)

	if distance > stop_distance:
		var direction = (target_pos - current_pos).normalized()
		var distance_multiplier = clamp(distance / stop_distance, 1.0, 5.0)
		var pull_strength = acceleration * distance_multiplier
		velocity += direction * pull_strength
		
		$AnimatedSprite2D.flip_h = direction.x < 0
	else:
		if $AnimationPlayer.has_animation("fly"):
			$AnimationPlayer.play("fly")

	velocity *= friction
	global_position += velocity * delta
