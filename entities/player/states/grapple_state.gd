# grapple_state.gd
extends State

var target_point: Vector2

func enter(msg := {}):
    if msg.has("point"):
        target_point = msg.point
        # Make the rope visible
        if player.has_node("Line2D"):
            player.get_node("Line2D").visible = true
    else:
        state_machine.transition_to("AirState")

func physics_update(delta: float):
    if player.has_node("Line2D"):
        var line = player.get_node("Line2D")
        line.visible = true
        line.clear_points() 
        line.add_point(player.global_position)
        line.add_point(target_point)

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
    # Hide rope
    if player.has_node("Line2D"):
        player.get_node("Line2D").visible = false
        
    # Optional: Give a 10% speed boost upon release to reward the timing
    player.velocity *= 1.1