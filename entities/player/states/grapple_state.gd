# grapple_state.gd
extends State

var target_point: Vector2
var weightless_duration: float = 0.25

func enter(msg := {}):
	if msg.has("point"):
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
	player.disable_gravity(weightless_duration) # 0.5 seconds of weightlessness

	state_machine.transition_to("AirState")



	# asdjf;alskdjf;lasjkdfl;akjsdf;lkja;lsdkfjasl;dfk
	# note to self, instead of a slime porjectile, just have the slime so that i can slide and use a resource counter that regenerates. I think the movement will
	# feel a lot better. 
	# I also don't want the slime to slide off the wall, but rather slide onto the wall. Maybe for now, forget spikes. But simply an obstacle course