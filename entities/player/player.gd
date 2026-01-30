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

@export_group("Grapple Settings")
@export var GRAPPLE_SPEED: float = 200.0
@export var GRAPPLE_ACCEL: float = 2500.0
@export var GRAPPLE_RANGE: float = 100.0
@onready var grapple_cast: RayCast2D = $GrappleCast # Make sure to add this node!
@onready var state_machine = $PlayerState  

# Calculate the jump velocity
var max_jump_velocity = -sqrt(2 * GRAVITY * JUMP_HEIGHT_MAX)
var min_jump_velocity = -sqrt(2 * GRAVITY * JUMP_HEIGHT_MIN)

var jump_buffer_timer: float = 0
var coyote_timer: SceneTreeTimer = null

func _physics_process(delta: float) -> void:
	_handle_jump_buffer(delta)
	_handle_grapple_input()

	
func _handle_jump_buffer(delta: float) -> void:
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta
	
	if Input.is_action_just_pressed("player_jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME

func _handle_grapple_input() -> void:
	if Input.is_action_just_pressed("player_grapple"):
		var mouse_pos = get_local_mouse_position()
		var dir_to_mouse = mouse_pos.normalized()
		
		grapple_cast.target_position = dir_to_mouse * GRAPPLE_RANGE
		grapple_cast.force_raycast_update()

		if grapple_cast.is_colliding():
			var point = grapple_cast.get_collision_point()
			state_machine.transition_to("GrappleState", {"point": point})
