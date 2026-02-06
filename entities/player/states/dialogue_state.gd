extends State


func enter(_msg: Dictionary = {}) -> void:
	player.anim_state.travel("idle")
	player.velocity = Vector2.ZERO
	player.dialogue_state += 1

func physics_update(delta: float) -> void:
	if not player.is_busy:
		state_machine.transition_to("IdleState")

	if not player.is_on_floor():
		player.velocity.y += player.GRAVITY * delta
		

	player.move_and_slide()

