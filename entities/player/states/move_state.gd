extends State

var sound_timer: Timer

func _ready() -> void:
	sound_timer = Timer.new()
	add_child(sound_timer)

	sound_timer.wait_time = .5
	sound_timer.one_shot = false
	sound_timer.timeout.connect(_on_timer_timeout)

func enter(_msg := {}) -> void:
	player.coyote_timer = null
	player.GRAPPLE_COUNT = player.GRAPPLE_COUNT_MAX
	player.anim_state.travel("move")

	if player.friction_coef < 1:
		if abs(player.velocity.x) > player.SPEED:
			var current_speed = abs(player.velocity.x)
			player.velocity.x = sign(player.velocity.x) * current_speed

	sound_timer.start()
	_on_timer_timeout()

var direction = Input.get_axis("player_left", "player_right")


func physics_update(delta: float):
	var was_on_floor: bool = player.is_on_floor()
	var input_dir = Input.get_axis("player_left", "player_right")
	var current_max_speed = player.SPEED * player.speed_multiplier
	var speed_diff = abs(player.velocity.x) - current_max_speed

	
	if input_dir != 0:
		var is_pushing_same_way = sign(input_dir) == sign(player.velocity.x)
		
		if speed_diff > 0 and is_pushing_same_way and player.friction_coef < 1:
			player.velocity.x = move_toward(player.velocity.x, input_dir * current_max_speed, player.FRICTION_AIR * player.friction_coef * delta)
		else:
			player.velocity.x = move_toward(player.velocity.x, input_dir * current_max_speed, player.ACCELERATION * delta)
	else:
		if player.edge_cast.is_colliding():
			player.velocity.x = move_toward(
				player.velocity.x, 
				0, 
				player.FRICTION * player.friction_coef * delta
			)
		else:
			player.velocity.x = 0
			print("true")

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

func exit() -> void:
	sound_timer.stop()

func _handle_animation(dir_x: float) -> void:
	if dir_x > 0:
		player.animated_sprite.flip_h = false
	elif dir_x < 0:
		player.animated_sprite.flip_h = true

func _on_timer_timeout() -> void:
	var pitch = randf_range(0.7, 1.0) 
	AudioLoader.play_sfx_2d_attached(player.move_sound, player, "Master", true, -12, pitch)
