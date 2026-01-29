extends State

func physics_update(delta: float):
	var input_dir = Input.get_axis("player_left", "player_right")
	
	if input_dir != 0:
		# ACCELERATE: Smoothly reach max SPEED
		player.velocity.x = move_toward(
			player.velocity.x, 
			input_dir * player.SPEED, 
			player.ACCELERATION * delta
		)
	else:
		# FRICTION: Smoothly come to a stop
		player.velocity.x = move_toward(
			player.velocity.x, 
			0, 
			player.FRICTION * delta
		)
	
	# Transition to AirState if we fall off a ledge
	if not player.is_on_floor():
		state_machine.transition_to("AirState")
	
	# Transition to Idle if we are basically stopped and no input
	if input_dir == 0 and is_equal_approx(player.velocity.x, 0):
		state_machine.transition_to("IdleState")
	
	if Input.is_action_just_pressed("player_jump"):
		state_machine.transition_to("AirState", {"do_jump": true})
		return
		
	player.move_and_slide()
	
