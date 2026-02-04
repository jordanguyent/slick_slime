extends State

var wall_timer: float

func enter(_msg: Dictionary = {}) -> void:
	wall_timer = player.wall_time
	player.velocity.y = 0
	player.gravity_disabled = false

func physics_update(delta: float) -> void:
	wall_timer -= delta

	if wall_timer < 0 or not player.is_on_wall():
		state_machine.transition_to("AirState")
		return

	if Input.is_action_just_pressed("player_jump"):
		state_machine.transition_to("AirState", {"do_jump": true})