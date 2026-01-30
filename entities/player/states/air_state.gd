extends State

func enter(msg := {}):
	if msg.has("do_jump"):
		player.velocity.y = player.max_jump_velocity
		if abs(player.velocity.x) > player.SPEED:
			var diff = abs(player.velocity.x) - player.SPEED
			var new_speed = player.SPEED + diff/2
			if sign(player.velocity.x) > 0:
				player.velocity.x = new_speed
			elif sign(player.velocity.x) < 0:
				player.velocity.x = new_speed * -1
				

func physics_update(delta: float):
	
	# Horizontal Movement
	var input_dir = Input.get_axis("player_left", "player_right")
	if input_dir != 0:
		if abs(player.velocity.x) < player.SPEED or sign(input_dir) != sign(player.velocity.x):
			player.velocity.x = move_toward(
				player.velocity.x, 
				input_dir * player.SPEED, 
				player.ACCELERATION * delta
			)
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, (player.FRICTION * 0.1) * delta)

	player.velocity.y += player.GRAVITY * delta

	var jump_released = Input.is_action_just_released("player_jump")
	var not_holding_jump = !Input.is_action_pressed("player_jump")

	if (jump_released or not_holding_jump):
		if player.velocity.y < player.min_jump_velocity:
			player.velocity.y = player.min_jump_velocity
	
	# When player is falling
	if player.velocity.y > player.TERMINAL_VELOCITY:
		player.velocity.y = player.TERMINAL_VELOCITY

	player.move_and_slide()

	# State Transitions
	if player.is_on_floor():
		if player.jump_buffer_timer > 0:
			player.jump_buffer_timer = 0
			state_machine.transition_to("AirState", {"do_jump": true})
		else:
			if is_equal_approx(player.velocity.x, 0):
				state_machine.transition_to("IdleState")
			else:
				state_machine.transition_to("MoveState")
