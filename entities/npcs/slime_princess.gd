extends CharacterBody2D

@onready var prompt = $Prompt
var is_player_in_range = false

func _ready():
	prompt.visible = false
	$TalkArea.body_entered.connect(_on_body_entered)
	$TalkArea.body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body is Player: 
		is_player_in_range = true
		prompt.visible = true

func _on_body_exited(body):
	if body is Player:
		is_player_in_range = false
		prompt.visible = false