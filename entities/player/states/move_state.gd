extends State

func enter(_msg := {}) -> void:
	player.coyote_timer = null

func physics_update(delta: float):
	var was_on_floor: bool = player.is_on_floor()
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

	player.move_and_slide()
	
	if was_on_floor and not player.is_on_floor() and player.velocity.y >= 0 and player.coyote_timer == null:
		player.coyote_timer = get_tree().create_timer(player.COYOTE_DURATION)
	
	print(player.coyote_timer)

	if is_instance_valid(player.coyote_timer) and player.coyote_timer.time_left > 0:
		if Input.is_action_just_pressed("player_jump"):
			player.coyote_timer = null
			state_machine.transition_to("AirState", {"do_jump": true})
	else:
		state_machine.transition_to("AirState")

	# Transition to Idle if we are basically stopped and no input
	if input_dir == 0 and is_equal_approx(player.velocity.x, 0):
		state_machine.transition_to("IdleState")
	
	if Input.is_action_just_pressed("player_jump"):
		state_machine.transition_to("AirState", {"do_jump": true})
		return
	
