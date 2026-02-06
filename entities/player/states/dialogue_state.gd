extends State


func enter(_msg: Dictionary = {}) -> void:
	player.anim_state.travel("idle")
	player.velocity = Vector2.ZERO

func physics_update(_delta: float) -> void:
	if not player.is_busy:
		state_machine.transition_to("IdleState")

