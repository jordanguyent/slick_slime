extends CharacterBody2D

@export_group("Movement Settings")
@export var SPEED = 100.0
@export var ACCELERATION = 2000.0
@export var ACCELERATION_SLIME = 100.0
@export var FRICTION_SLIME = 100.0
@export var FRICTION = 3000.0
@export var FRICTION_AIR = 150.0
@export var FRICTION_SLIDE = 300.0
@export var GRAVITY = 600.0
@export var TERMINAL_VELOCITY = 200.0
@export var JUMP_HEIGHT_MAX: float = 42.0
@export var JUMP_HEIGHT_MIN: float = 12.0
@export var JUMP_BUFFER_TIME: float = 0.15
@export var COYOTE_DURATION: float = 0.15 # Duration in seconds
@export var SPEED_X_MAX: int = 400
@export var SPEED_Y_MAX: int = 400

@export_group("Grapple Settings")
@export var GRAPPLE_SPEED: float = 200.0
@export var GRAPPLE_RANGE: float = 65.0
@export var GRAPPLE_COUNT_MAX: int =1 
@export var GRAPPLE_COUNT: int = 1:
	set(value):
		GRAPPLE_COUNT = clamp(value, 0, GRAPPLE_COUNT_MAX)

@export var wall_time: float = 1.0

@export_group("Slime Settings")
@export var target_tile_coords_list: Array[Vector2i] = [Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)] 
@export var slime_atlas_coords_list: Array[Vector2i] = [Vector2i(1, 3), Vector2i(2, 3), Vector2i(3, 3)]
@export var source_id: int = 0


@onready var grapple_cast: RayCast2D = $GrappleCast # Make sure to add this node!
@onready var collision_shape: CollisionShape2D = $CollisionShape2D 
@onready var state_machine = $PlayerState
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var anim_tree: AnimationTree = $AnimationTree
@onready var anim_state = anim_tree.get("parameters/playback")
@onready var hurt_box: Area2D = $HurtBox
var level_node: Node2D

var collision_shape_original_size: Vector2

var max_jump_velocity = -sqrt(2 * GRAVITY * JUMP_HEIGHT_MAX)
var min_jump_velocity = -sqrt(2 * GRAVITY * JUMP_HEIGHT_MIN)

var player_center_offset: float = -5.0

var jump_buffer_timer: float = 0
var coyote_timer: SceneTreeTimer = null

var preview_point = null 
var gravity_disabled: bool = false
var post_grapple: bool = false
var friction_coef: float = 1.0
var last_tile_pos: Vector2i = Vector2i(-1, -1)
var jump_param = "parameters/air/blend_position"
var tile_map: TileMapLayer:
	set(value):
		tile_map = value
		last_tile_pos = Vector2i(-1, -1)

func _ready() -> void:
	Game.collected.connect(_collectable_retrieved)
	collision_shape_original_size = collision_shape.shape.size
	hurt_box.body_entered.connect(_on_body_entered_hurt_box)
	level_node = get_parent()


func _physics_process(delta: float) -> void:
	if not tile_map: return

	if abs(velocity.x) > SPEED_X_MAX:
		velocity.x = sign(velocity.x) * SPEED_X_MAX
	if abs(velocity.y) > SPEED_Y_MAX:
		velocity.y = sign(velocity.y) * SPEED_Y_MAX

	anim_tree.set(jump_param, velocity)
		
	_get_friction_at_feet()
	_handle_jump_buffer(delta)
	_update_grapple_preview()
	_handle_grapple_input()

func disable_gravity(duration: float, post_duration: float):
	gravity_disabled = true
	await get_tree().create_timer(duration).timeout
	gravity_disabled = false
	post_grapple = true
	await get_tree().create_timer(post_duration).timeout
	post_grapple = false

func _get_friction_at_feet() -> void:
	var feet_offset = Vector2(0, (collision_shape_original_size.y / 2) + 2)
	var local_pos = tile_map.to_local(global_position + feet_offset)
	var tile_pos = tile_map.local_to_map(local_pos)
	
	var data = tile_map.get_cell_tile_data(tile_pos)

	if data:
		friction_coef = data.get_custom_data("friction_coef")
	else:
		friction_coef = 1.0

func apply_slime_trail() -> void:
	if not tile_map:
		return

	var feet_offset = Vector2(0, (collision_shape_original_size.y / 2) + 2)
	var current_tile_pos = tile_map.local_to_map(tile_map.to_local(global_position + feet_offset))

	if last_tile_pos == Vector2i(-1, -1):
		last_tile_pos = current_tile_pos
		return

	if current_tile_pos != last_tile_pos:
		_process_slime_on_previous_tile(last_tile_pos)
		last_tile_pos = current_tile_pos

func _process_slime_on_previous_tile(pos: Vector2i) -> void:
	if pos == Vector2i(-1, -1):
		return
		
	var atlas_coords = tile_map.get_cell_atlas_coords(pos)
	print(atlas_coords)

	if atlas_coords in target_tile_coords_list:
		var index = target_tile_coords_list.find(atlas_coords)
		var slime_atlas_coords = slime_atlas_coords_list[index]
		tile_map.set_cell(pos, source_id, slime_atlas_coords)

func _on_body_entered_hurt_box(_body: Node2D) -> void:
	var level = get_tree().current_scene
	if level.has_method("respawn_player"):
		level.call_deferred("respawn_player")
	else:
		get_tree().call_deferred("reload_current_scene")
	
func _handle_jump_buffer(delta: float) -> void:
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta
	
	if Input.is_action_just_pressed("player_jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME

func _update_grapple_preview() -> void:
	var mouse_pos = get_local_mouse_position()

	var target_pos = mouse_pos
	if mouse_pos.length() > GRAPPLE_RANGE:
		target_pos = mouse_pos.normalized() * GRAPPLE_RANGE

	grapple_cast.target_position = target_pos
	grapple_cast.force_raycast_update()

	if grapple_cast.is_colliding():
		preview_point = grapple_cast.get_collision_point()
	else:
		preview_point = null

	if GRAPPLE_COUNT > 0:
		animated_sprite.modulate = Color(0.2, 0.5, 1.0)
	else:
		animated_sprite.modulate = Color.WHITE

	queue_redraw()

func _handle_grapple_input() -> void:
	if Input.is_action_just_pressed("player_grapple") and GRAPPLE_COUNT > 0:
		if grapple_cast.is_colliding():
			var point = grapple_cast.get_collision_point()
			GRAPPLE_COUNT -= 1
			state_machine.transition_to("GrappleState", {"point": point})
			
			
func _draw() -> void:
	# 1. Draw the Dotted Range Circle (Local Space)
	var circle_color = Color(1, 1, 1, 0.1)
	var line_width = 0.5
	var dash_count = 64 # Total number of dots/dashes
	var dash_length = TAU / (dash_count * 2) # Length of each dash in radians

	for i in range(dash_count):
		var start_angle = i * (TAU / dash_count)
		var end_angle = start_angle + dash_length
		draw_arc(Vector2.ZERO, GRAPPLE_RANGE, start_angle, end_angle, 4, circle_color, line_width)

	# 2. Draw the Preview Point (World Space)
	draw_set_transform(-global_position, 0, Vector2.ONE)
	if preview_point != null:
		draw_circle(preview_point, 3.0, Color(1, 1, 1, 0.6))

func _collectable_retrieved(collectable: Collectable) -> void:
	if collectable is SlimeOrb:
		GRAPPLE_COUNT = 1
