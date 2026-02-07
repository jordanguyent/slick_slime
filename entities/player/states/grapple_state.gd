# grapple_state.gd
extends State

var target_point: Vector2
var weightless_duration: float = 0.225
var post_duration: float = 0.05
var prev_velocity: Vector2

func enter(msg := {}):
	if msg.has("point"):
		prev_velocity = player.velocity
		player.velocity = Vector2.ZERO

		target_point = msg.point
		launch_player(target_point)
	else:
		state_machine.transition_to("AirState")
	var pitch = randf_range(0.8, 1.0) 
	AudioLoader.play_sfx_2d_attached(player.grapple_sound, player, "Master", true, -7, pitch)

func launch_player(target: Vector2):
	var to_target = target - player.global_position
	var direction = to_target.normalized()
	var grapple_speed = max(player.GRAPPLE_SPEED, prev_velocity.length())

	# Apply the massive slingshot velocit
	player.velocity = direction * grapple_speed

	# Tell the player to ignore gravity for a moment
	player.disable_gravity(weightless_duration, post_duration)

	state_machine.transition_to("AirState")

func exit() -> void:
	if sign(player.velocity.x) > 0:
		player.animated_sprite.flip_h = false
	elif sign(player.velocity.x) < 0:
		player.animated_sprite.flip_h = true
