extends State

func enter(_msg := {}):
	player.velocity.x = 0
	player.GRAPPLE_COUNT = player.GRAPPLE_COUNT_MAX
	player.anim_state.travel("idle")

func physics_update(_delta: float):

	# State Transitions
	if not player.is_on_floor():
		state_machine.transition_to("AirState")
		return

	var input_dir = Input.get_axis("player_left", "player_right")
	if input_dir != 0:
		state_machine.transition_to("MoveState")
		return

	if Input.is_action_just_pressed("player_jump"):
		state_machine.transition_to("AirState", {"do_jump": true})
		return
		
