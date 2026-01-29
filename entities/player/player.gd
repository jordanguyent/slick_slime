extends CharacterBody2D

@export_group("Movement Settings")
@export var SPEED = 75.0
@export var ACCELERATION = 2000.0
@export var FRICTION = 3000.0
@export var GRAVITY = 600.0
@export var TERMINAL_VELOCITY = 200.0
@export var JUMP_HEIGHT_MAX: float = 40.0
@export var JUMP_HEIGHT_MIN: float = 16.0
@export var JUMP_BUFFER_TIME: float = 0.2 
@export var COYOTE_DURATION: float = 0.15 # Duration in seconds

# Calculate the jump velocity
var max_jump_velocity = -sqrt(2 * GRAVITY * JUMP_HEIGHT_MAX)
var min_jump_velocity = -sqrt(2 * GRAVITY * JUMP_HEIGHT_MIN)

var jump_buffer_timer: float = 0
var coyote_timer: SceneTreeTimer = null

func _physics_process(delta: float) -> void:
    _handle_jump_buffer(delta)

    
func _handle_jump_buffer(delta: float) -> void:
    if jump_buffer_timer > 0:
        jump_buffer_timer -= delta
    
    if Input.is_action_just_pressed("player_jump"):
        jump_buffer_timer = JUMP_BUFFER_TIME