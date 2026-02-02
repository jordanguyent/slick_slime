class_name SlideState extends State

func enter(_msg: Dictionary = {}) -> void:
	pass

func physics_update(delta: float) -> void:
	player.slime_resource -= delta * player.slide_cost
	player.velocity.x =	move_toward(player.velocity.x, 0, player.FRICTION_SLIDE * delta)

	player.move_and_slide()

	_handle_transitions()
	

func _handle_transitions() -> void:
	if not player.is_on_floor():
		state_machine.transition_to("AirState")
		return

	if player.slime_resource <= 0:
		state_machine.transition_to("MoveState")
		return
	
	if Input.is_action_just_pressed("player_jump"):
		state_machine.transition_to("AirState", {"do_jump": true})
	elif Input.is_action_just_released("player_down"):
		state_machine.transition_to("MoveState")
		