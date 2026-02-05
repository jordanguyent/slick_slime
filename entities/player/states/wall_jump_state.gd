extends State

var wall_jump_timer: SceneTreeTimer

func _ready() -> void:
	wall_jump_timer = get_tree().create_timer(0.1)

func enter(msg: Dictionary = {}) -> void:
	player.velocity.y = player.max_jump_velocity
	if msg.has("do_wall_jump"):
		var wall_normal = msg.get("do_wall_jump")
		player.velocity.x = wall_normal.x * player.SPEED

func physics_update(delta: float) -> void:

	player.velocity.y += player.GRAVITY * delta
	if player.velocity.y > player.TERMINAL_VELOCITY:
		player.velocity.y = player.TERMINAL_VELOCITY

	player.move_and_slide()

	if wall_jump_timer == null or wall_jump_timer.time_left <= 0:
		state_machine.transition_to("AirState", {"do_jump": true})
