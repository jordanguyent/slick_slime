extends State

func enter(msg := {}):
	if msg.has("do_jump"):
		player.velocity.y = player.JUMP_VELOCITY

func physics_update(delta: float):
	
	var input_dir = Input.get_axis("player_left", "player_right")
	if input_dir != 0:
		player.velocity.x = move_toward(
			player.velocity.x, 
			input_dir * player.SPEED, 
			player.ACCELERATION * delta
		)
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, player.FRICTION * delta)

	player.velocity.y += player.GRAVITY * delta
	
	if player.velocity.y > player.TERMINAL_VELOCITY:
		player.velocity.y = player.TERMINAL_VELOCITY

	player.move_and_slide()

	if player.is_on_floor():
		if is_equal_approx(player.velocity.x, 0):
			state_machine.transition_to("IdleState")
		else:
			state_machine.transition_to("MoveState")
