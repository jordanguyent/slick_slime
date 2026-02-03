extends CharacterBody2D

var SPEED: float = 500.0
var velocity_vector: Vector2

func _ready() -> void:
    # Set direction once toward mouse
    var mouse_pos = get_local_mouse_position()
    velocity_vector = mouse_pos.normalized() * SPEED

func _physics_process(delta: float) -> void:
    # move_and_collide returns a KinematicCollision2D object upon impact
    var collision = move_and_collide(velocity_vector * delta)
    
    if collision:
        queue_free()