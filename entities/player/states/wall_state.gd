extends State

var wall_timer: float

func enter(_msg: Dictionary = {}) -> void:
	wall_timer = player.wall_time
	player.velocity.y = 0
	player.gravity_disabled = false
	player.anim_state.travel("wall")

	if player.is_on_wall():
		var wall_normal = player.get_wall_normal()
		
		if wall_normal.x > 0:
			player.animated_sprite.flip_h = false # Look Right
		elif wall_normal.x < 0:
			player.animated_sprite.flip_h = true  # Look Left

func physics_update(delta: float) -> void:
	wall_timer -= delta

	player.move_and_slide()

	if wall_timer < 0 or not player.is_on_wall():
		state_machine.transition_to("AirState")
		return

	if Input.is_action_just_pressed("player_jump"):
		state_machine.transition_to("WallJumpState", {"do_wall_jump": player.get_wall_normal()})
	if Input.is_action_just_pressed("player_down"):
		state_machine.transition_to("AirState")