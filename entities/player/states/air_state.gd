extends State

func enter(msg := {}):
	if msg.has("do_jump"):
		player.velocity.y = player.max_jump_velocity
		AudioLoader.play_sfx_deferred(player.jump_sound)
		
		# SLIME/SLIDE CONSERVATION
		# Check if we were already moving fast (from a slide or slime)
		if abs(player.velocity.x) > player.SPEED:
			# We multiply the current speed by a small bonus or just keep it
			# This ensures the 'launch' feeling
			var boost: float = 1.0
			if player.friction_coef < 0.5:
				if msg.has("from_slide"):
					boost = player.SLIME_BOOST
				else:
					boost = player.SLIDE_BOOST
			else:
				if msg.has("from_slide"):
					boost = player.SLIDE_BOOST

			player.velocity.x *= boost 
			
			
	player.anim_state.travel("air")

func physics_update(delta: float):
	var speed_diff = abs(player.velocity.x) - player.SPEED
	var input_dir = Input.get_axis("player_left", "player_right")

	if not player.gravity_disabled and not player.post_grapple:
		if input_dir != 0:
			var is_pushing_same_way = sign(input_dir) == sign(player.velocity.x)
			
			if speed_diff > 0 and is_pushing_same_way:
				player.velocity.x = move_toward(player.velocity.x, input_dir * player.SPEED, player.FRICTION_AIR * delta)
			else:
				player.velocity.x = move_toward(player.velocity.x, input_dir * player.SPEED, player.ACCELERATION * delta)
		else:
			var decay = player.FRICTION_AIR
			if speed_diff > 0:
				decay *= 2.0 
			player.velocity.x = move_toward(player.velocity.x, 0, decay * delta)

		player.velocity.y += player.GRAVITY * delta
		if player.velocity.y > player.TERMINAL_VELOCITY:
			player.velocity.y = player.TERMINAL_VELOCITY

		# 3. Short Jump Logic (Variable Jump Height)
		if Input.is_action_just_released("player_jump") and player.velocity.y < player.min_jump_velocity:
			player.velocity.y = player.min_jump_velocity

	else:
		if player.post_grapple:
			player.velocity = player.velocity.move_toward(Vector2.ZERO, player.FRICTION_AIR * 10 * delta)

		if player.is_on_wall():
			state_machine.transition_to("WallState")

	player.move_and_slide()

	_handle_animation(input_dir)

	# 2. Check for high-speed wall impact
	if player.is_on_wall():
		if speed_diff > 0:
			state_machine.transition_to("WallState")

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

func _handle_animation(dir_x: float) -> void:
	if player.is_on_wall():
		var wall_normal = player.get_wall_normal()
		player.animated_sprite.flip_h = (wall_normal.x < 0)
	elif dir_x != 0:
		player.animated_sprite.flip_h = (dir_x < 0)

func _exit() -> void:
	pass
