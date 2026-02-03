extends State

func enter(_msg := {}) -> void:
	player.coyote_timer = null
	player.GRAPPLE_COUNT = player.GRAPPLE_COUNT_MAX
	player.animated_sprite.play("move")

func physics_update(delta: float):
	var was_on_floor: bool = player.is_on_floor()
	var input_dir = Input.get_axis("player_left", "player_right")
	
	if input_dir != 0:
		player.velocity.x = move_toward(
			player.velocity.x, 
			input_dir * player.SPEED, 
			player.ACCELERATION * delta
		)
	else:
		player.velocity.x = move_toward(
			player.velocity.x, 
			0, 
			player.FRICTION * delta
		)

	player.move_and_slide()

	_handle_animation(input_dir)
	
	if was_on_floor and not player.is_on_floor() and player.velocity.y >= 0:
		player.coyote_timer = get_tree().create_timer(player.COYOTE_DURATION)

	if not player.is_on_floor():
		if is_instance_valid(player.coyote_timer) and player.coyote_timer.time_left > 0:
			if Input.is_action_just_pressed("player_jump"):
				player.coyote_timer = null
				state_machine.transition_to("AirState", {"do_jump": true})
		else:
			state_machine.transition_to("AirState")
		return

	if Input.is_action_just_pressed("player_jump"):
		state_machine.transition_to("AirState", {"do_jump": true})
	elif Input.is_action_just_pressed("player_down"):
		state_machine.transition_to("SlideState")
	elif input_dir == 0 and is_equal_approx(player.velocity.x, 0):
		state_machine.transition_to("IdleState")

func _handle_animation(dir_x: float) -> void:
	if dir_x > 0:
		player.animated_sprite.flip_h = false
	elif dir_x < 0:
		player.animated_sprite.flip_h = true
