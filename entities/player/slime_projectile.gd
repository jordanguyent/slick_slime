extends CharacterBody2D

@export var impact_effect: PackedScene
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
        spawn_impact_effect(collision)
        queue_free()

func spawn_impact_effect(collision: KinematicCollision2D):
    if impact_effect:
        var effect = impact_effect.instantiate()
        get_tree().current_scene.add_child.call_deferred(effect)
        
        # This is the exact point of contact on the physics shape
        effect.global_position = collision.get_position()
        
        # Get the surface normal (direction the wall faces)
        var normal = collision.get_normal()
        effect.global_rotation = normal.angle() + PI/2
        
        # Optional: Add a tiny nudge so it doesn't clip into the floor
        effect.global_position += normal * 0.5