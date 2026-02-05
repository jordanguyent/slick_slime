extends State

var death_timer: float = 0.5 # Reduced because the animation takes time

func enter(_msg: Dictionary = {}) -> void:
	player.velocity = Vector2.ZERO
	player.anim_state.travel("death")
	_handle_death_sequence()

func _handle_death_sequence() -> void:
	await get_tree().create_timer(death_timer).timeout

	await player.level_node.level_ui.play_exit_transition()

	_reset()

	await player.level_node.level_ui.play_enter_transition()

func _reset() -> void:
	var level = get_tree().current_scene
	if level.has_method("respawn_player"):
		level.call_deferred("respawn_player")
	else:
		get_tree().call_deferred("reload_current_scene")

	state_machine.transition_to("IdleState")
