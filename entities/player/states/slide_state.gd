class_name SlideState extends State

var sound_timer: Timer

func _ready() -> void:
	sound_timer = Timer.new()
	add_child(sound_timer)

	sound_timer.wait_time = 1
	sound_timer.one_shot = false
	sound_timer.timeout.connect(_on_timer_timeout)

func enter(_msg: Dictionary = {}) -> void:
	player.GRAPPLE_COUNT = player.GRAPPLE_COUNT_MAX
	player.velocity.x = sign(player.velocity.x) * player.velocity.length()
	player.collision_shape.shape.size = player.collision_shape_original_size * 0.5
	player.collision_shape.position.y += (player.collision_shape_original_size.y / 4)
	player.anim_state.travel("slide")
	player.reset_trail_tracking()
	sound_timer.start()
	_on_timer_timeout()

func physics_update(delta: float) -> void:
	player.velocity.x =	move_toward(player.velocity.x, 0, player.FRICTION_SLIDE * player.friction_coef * delta)

	player.move_and_slide()
	player.apply_slime_trail()
	_handle_transitions()
	

func _handle_transitions() -> void:
	if not player.is_on_floor():
		state_machine.transition_to("AirState")
		return
	
	if Input.is_action_just_pressed("player_jump"):
		state_machine.transition_to("AirState", {"do_jump": true, "from_slide": true})
	elif Input.is_action_just_released("player_down"):
		state_machine.transition_to("MoveState")

func exit() -> void:
	player.collision_shape.shape.size = player.collision_shape_original_size
	player.collision_shape.position.y -= (player.collision_shape_original_size.y / 4)
	sound_timer.stop()

func _on_timer_timeout() -> void:
	if player.velocity.x != 0:
		var pitch = randf_range(0.7, 1.0) 
		AudioLoader.play_sfx_2d_attached(player.slide_sound, player, "Master", true, -12, pitch)