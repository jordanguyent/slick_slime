class_name StateController extends Node2D

@export var initial_state: NodePath
@onready var state: State = get_node(initial_state)

func _ready():
	# Wait for the owner (Player) to be ready
	await owner.ready

	# Initialize all child states by giving them references to the player and machine
	for child in get_children():
		child.player = owner as CharacterBody2D
		child.state_machine = self

	state.enter()

func _physics_process(delta):
	state.physics_update(delta)

func _unhandled_input(event):
	state.handle_input(event)

func transition_to(target_state_name: String, msg: Dictionary = {}):
	if not has_node(target_state_name):
		return

	state.exit()
	state = get_node(target_state_name)
	state.enter(msg)
	print("State changed to: ", target_state_name)
