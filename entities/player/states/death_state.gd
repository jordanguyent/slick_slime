extends State

var death_timer: float = 2.0

func enter(_msg: Dictionary = {}) -> void:
	player.velocity = Vector2.ZERO
	player.anim_state.travel("death")

	get_tree().create_timer(death_timer).timeout.connect(_on_timeout)

func physics_update(_delta: float) -> void:
	player.velocity = Vector2.ZERO

func _on_timeout() -> void:
	_reset()

func _reset() -> void:
	var level = get_tree().current_scene
	if level.has_method("respawn_player"):
		level.call_deferred("respawn_player")
	else:
		get_tree().call_deferred("reload_current_scene")

	state_machine.transition_to("IdleState")