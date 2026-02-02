extends State

func enter(msg := {}):
	if msg.has("do_jump"):
		player.velocity.y = player.max_jump_velocity
        
		# Conserve Slime Momentum
		if abs(player.velocity.x) > player.SPEED:
			var current_speed = abs(player.velocity.x)
			player.velocity.x = sign(player.velocity.x) * current_speed
func physics_update(delta: float):
	
	var input_dir = Input.get_axis("player_left", "player_right")
	var speed_diff = abs(player.velocity.x) - player.SPEED

	if input_dir != 0:
		var is_pushing_same_way = sign(input_dir) == sign(player.velocity.x)
		
		if speed_diff > 0 and is_pushing_same_way:
			player.velocity.x = move_toward(player.velocity.x, input_dir * player.SPEED, player.FRICTION_AIR * 0.5 * delta)
		else:
			player.velocity.x = move_toward(player.velocity.x, input_dir * player.SPEED, player.ACCELERATION * delta)
	else:
		# No input: apply heavier friction if we're going fast to "punish" lack of control
		var decay = player.FRICTION_AIR
		if speed_diff > 0:
			decay *= 2.0 # Double friction when speeding with no input
		player.velocity.x = move_toward(player.velocity.x, 0, decay * delta)

	# 2. Gravity Logic
	if not player.gravity_disabled:
		player.velocity.y += player.GRAVITY * delta
		# Cap falling speed
		if player.velocity.y > player.TERMINAL_VELOCITY:
			player.velocity.y = player.TERMINAL_VELOCITY
	else:
		# Weightless period: You can optionally add a tiny bit of 
		# vertical air friction so they don't fly UP forever
		player.velocity.y = move_toward(player.velocity.y, 0, player.FRICTION_AIR * 0.1 * delta)

	# 3. Short Jump Logic (Variable Jump Height)
	if Input.is_action_just_released("player_jump") and player.velocity.y < player.min_jump_velocity:
		player.velocity.y = player.min_jump_velocity

	player.move_and_slide()

	# State Transitions
	if player.is_on_floor():
		if player.jump_buffer_timer > 0:
			player.jump_buffer_timer = 0
			state_machine.transition_to("AirState", {"do_jump": true})
		else:
			if is_equal_approx(player.velocity.x, 0):
				state_machine.transition_to("IdleState")
			elif Input.is_action_pressed("player_down"):
				state_machine.transition_to("SlideState")
			else:
				state_machine.transition_to("MoveState")
