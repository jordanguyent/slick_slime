# grapple_state.gd
extends State

var target_point: Vector2

func enter(msg := {}):
    if msg.has("point"):
        target_point = msg.point
        player.active_grapple_point = msg.point # Pushing the data to the player
    else:
        state_machine.transition_to("AirState")

func physics_update(delta: float):

    # Movement Logic
    var direction = (target_point - player.global_position).normalized()
    
    # We use move_toward to ramp up to GRAPPLE_SPEED
    player.velocity = player.velocity.move_toward(
        direction * player.GRAPPLE_SPEED,
        player.GRAPPLE_ACCEL * delta
    )
    
    player.move_and_slide()

    # Release Logic
    if Input.is_action_just_released("player_grapple"):
        state_machine.transition_to("AirState")
    
    # Auto-release if we get close to the hook
    if player.global_position.distance_to(target_point) < 20:
        state_machine.transition_to("AirState")

func exit():
    player.active_grapple_point = null # Clear it when the grapple ends
    # Optional: Give a 10% speed boost upon release to reward the timing
    player.velocity *= 1.1