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
@export var GRAPPLE_SPEED: float = 225.0
@export var GRAPPLE_ACCEL: float = 2500.0
@export var GRAPPLE_RANGE: float = 100.0
@export var GRAPPLE_COUNT: int = 1
@onready var grapple_cast: RayCast2D = $GrappleCast # Make sure to add this node!
@onready var state_machine = $PlayerState  

# Calculate the jump velocity
var max_jump_velocity = -sqrt(2 * GRAVITY * JUMP_HEIGHT_MAX)
var min_jump_velocity = -sqrt(2 * GRAVITY * JUMP_HEIGHT_MIN)

var jump_buffer_timer: float = 0
var coyote_timer: SceneTreeTimer = null

var preview_point = null 
var active_grapple_point = null

func _physics_process(delta: float) -> void:
	_handle_jump_buffer(delta)
	_update_grapple_preview()
	_handle_grapple_input()

	
func _handle_jump_buffer(delta: float) -> void:
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta
	
	if Input.is_action_just_pressed("player_jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME

func _update_grapple_preview() -> void:
	var mouse_pos = get_local_mouse_position()
	var dir_to_mouse = mouse_pos.normalized()

	grapple_cast.target_position = dir_to_mouse * GRAPPLE_RANGE
	grapple_cast.force_raycast_update()

	if grapple_cast.is_colliding():
		preview_point = grapple_cast.get_collision_point()
	else:
		preview_point = null

	queue_redraw()

func _handle_grapple_input() -> void:
	if Input.is_action_just_pressed("player_grapple") and GRAPPLE_COUNT > 0:
		if grapple_cast.is_colliding():
			var point = grapple_cast.get_collision_point()
			GRAPPLE_COUNT -= 1
			state_machine.transition_to("GrappleState", {"point": point})
			
func _draw() -> void:
	# 1. Reset the coordinate system so we draw in "World Space"
	# This detaches the drawing from the player's jittery movement
	draw_set_transform(-global_position, 0, Vector2.ONE)

	# 2. Draw the Preview (when aiming)
	if preview_point != null and active_grapple_point == null:
		draw_circle(preview_point, 3.0, Color(1, 1, 1, 0.6))

	# 3. Draw the Active Grapple (when zipping)
	if active_grapple_point != null:
		# Use global_position for the player's end of the rope
		# and active_grapple_point for the wall end
		draw_line(global_position + Vector2(0, -5), active_grapple_point, Color(0.75, 1.0, 0, 1), 2.0)
		draw_circle(active_grapple_point, 5.0, Color(0.75, 1.0, 0, 1))
