# grapple_state.gd
extends State

var target_point: Vector2
var weightless_duration: float = 0.225
var post_duration: float = 0.05

func enter(msg := {}):
	if msg.has("point"):
		player.velocity *= 0

		target_point = msg.point
		launch_player(target_point)
	else:
		state_machine.transition_to("AirState")

func launch_player(target: Vector2):
	var to_target = target - player.global_position
	var direction = to_target.normalized()

	# Apply the massive slingshot velocity
	player.velocity = direction * (player.velocity.length() + player.GRAPPLE_SPEED)

	# Tell the player to ignore gravity for a moment
	player.disable_gravity(weightless_duration, post_duration)

	state_machine.transition_to("AirState")

func exit() -> void:
	if sign(player.velocity.x) > 0:
		player.animated_sprite.flip_h = false
	elif sign(player.velocity.x) < 0:
		player.animated_sprite.flip_h = true