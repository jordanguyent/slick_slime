extends CharacterBody2D

@export_group("Movement Settings")
@export var SPEED = 100.0
@export var ACCELERATION = 2000.0
@export var ACCELERATION_SLIME = 100.0
@export var FRICTION_SLIME = 100.0
@export var FRICTION = 3000.0
@export var FRICTION_AIR = 150.0
@export var FRICTION_SLIDE = 100.0
@export var GRAVITY = 600.0
@export var TERMINAL_VELOCITY = 200.0
@export var JUMP_HEIGHT_MAX: float = 40.0
@export var JUMP_HEIGHT_MIN: float = 16.0
@export var JUMP_BUFFER_TIME: float = 0.15
@export var COYOTE_DURATION: float = 0.15 # Duration in seconds

@export_group("Grapple Settings")
@export var GRAPPLE_SPEED: float = 150.0
@export var GRAPPLE_RANGE: float = 100.0
@export var grapple_cost: int = 30
@onready var grapple_cast: RayCast2D = $GrappleCast # Make sure to add this node!
@onready var state_machine = $PlayerState

@export_group("Slime Settings")
@export var SLIME_COUNT: int = 1
@export var SLIME_SPEED: float = 500.0
@export var slime_projectile: PackedScene
@export var slime_resource: float = 100.0:
	set(value):
		slime_resource = clamp(value, 0, 100)
		slime_resource_changed.emit(slime_resource)
@export var slide_cost: int = 20
@export var slime_regen: int = 20

signal slime_resource_changed(new_value)

var max_jump_velocity = -sqrt(2 * GRAVITY * JUMP_HEIGHT_MAX)
var min_jump_velocity = -sqrt(2 * GRAVITY * JUMP_HEIGHT_MIN)

var player_center_offset: float = -5.0

var jump_buffer_timer: float = 0
var coyote_timer: SceneTreeTimer = null

var preview_point = null 
var gravity_disabled: bool = false

func _ready() -> void:
	Game.slimed.connect(_is_slimed)
	Game.collected.connect(_collectable_retrieved)

func _physics_process(delta: float) -> void:

	if state_machine.state is not SlideState:
		slime_resource += slime_regen * delta

	_handle_jump_buffer(delta)
	_update_grapple_preview()
	_handle_grapple_input()

func disable_gravity(duration: float):
	gravity_disabled = true
	await get_tree().create_timer(duration).timeout
	gravity_disabled = false

	
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
	if Input.is_action_just_pressed("player_grapple") and slime_resource > grapple_cost:
		if grapple_cast.is_colliding():
			var point = grapple_cast.get_collision_point()
			slime_resource -= grapple_cost
			state_machine.transition_to("GrappleState", {"point": point})
			
			
func _draw() -> void:
	# Reset the coordinate system so we draw in "World Space"
	# This detaches the drawing from the player's jittery movement
	draw_set_transform(-global_position, 0, Vector2.ONE)

	# Draw the Preview (when aiming)
	if preview_point != null:
		draw_circle(preview_point, 3.0, Color(1, 1, 1, 0.6))

func _handle_slime_input() -> void:
	# fire a shot toward mouse
	# collides with tileset
	# generate an area2D where if player is in it, then player slides and movement resets. 
	if Input.is_action_just_pressed("player_slime") and SLIME_COUNT > 0:
		_create_slime_project()


func _create_slime_project() -> void:
	var proj_inst = slime_projectile.instantiate()
	proj_inst.top_level = true
	proj_inst.global_position = global_position + Vector2(0, player_center_offset)
	add_child(proj_inst)

func _is_slimed(is_slimed: bool) -> void:
	if is_slimed:
		state_machine.transition_to("SlimeState")
	else:
		state_machine.transition_to("MoveState")

func _collectable_retrieved(collectable: Collectable) -> void:
	if collectable is SlimeCoin:
		print("collected")
