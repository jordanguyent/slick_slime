class_name Player extends CharacterBody2D

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
@export var GRAPPLE_MARGIN: float = 20
@export var wall_time: float = 1.0

@export_group("Slime Settings")
@export var source_id: int = 0
@export var SLIME_BOOST: float = 1.5
@export var SLIDE_BOOST: float = 1.2


@onready var grapple_cast: RayCast2D = $GrappleCast # Make sure to add this node!
@onready var collision_shape: CollisionShape2D = $CollisionShape2D 
@onready var state_machine = $PlayerState
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var anim_tree: AnimationTree = $AnimationTree
@onready var anim_state = anim_tree.get("parameters/playback")
@onready var hurt_box: Area2D = $HurtBox
@onready var edge_cast: RayCast2D = $EdgeCast
var is_busy: bool = false
var level_node: Node2D

var collision_shape_original_size: Vector2

var max_jump_velocity = -sqrt(2 * GRAVITY * JUMP_HEIGHT_MAX)
var min_jump_velocity = -sqrt(2 * GRAVITY * JUMP_HEIGHT_MIN)

var player_center_offset: float = -5.0

var jump_buffer_timer: float = 0
var coyote_timer: SceneTreeTimer = null

var preview_point = null 
var grapple_point = null
var gravity_disabled: bool = false
var post_grapple: bool = false
var friction_coef: float = 1.0
var speed_multiplier: float = 1.0:
	get:
		return 1.5 if friction_coef < 0.5 else 1.0
var last_tile_pos: Vector2i = Vector2i(-1, -1)
var jump_param = "parameters/air/blend_position"
var tile_map: TileMapLayer:
	set(value):
		tile_map = value
		last_tile_pos = Vector2i(-1, -1)
var slime_map: TileMapLayer
var is_alive = true
var in_dialogue = false
var dialogue_state = 0
var game_end = false
signal level_finished()

# Sounds
var grapple_sound = preload("res://sounds/sfx/plorp.wav")
var jump_sound = preload("res://sounds/sfx/plorp.wav")

func _ready() -> void:
	Game.collected.connect(_collectable_retrieved)
	collision_shape_original_size = collision_shape.shape.size
	hurt_box.body_entered.connect(_on_body_entered_hurt_box)
	level_node = get_parent()

func _physics_process(delta: float) -> void:
	if not slime_map: return

	if is_busy and not in_dialogue:
		state_machine.transition_to("DialogueState")
		in_dialogue = true
		
	if is_alive and not is_busy:
		if abs(velocity.x) > SPEED_X_MAX:
			velocity.x = sign(velocity.x) * SPEED_X_MAX
		if abs(velocity.y) > SPEED_Y_MAX:
			velocity.y = sign(velocity.y) * SPEED_Y_MAX

		anim_tree.set(jump_param, velocity)
			
		_get_friction_at_feet()
		_handle_jump_buffer(delta)
		_update_grapple_preview()
		_handle_grapple_input()


		if dialogue_state == 3 and not game_end:
			game_end = true
			level_finished.emit()

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
	
	if slime_map and slime_map.get_cell_source_id(tile_pos) != -1:
		friction_coef = 0.1 
	else:
		var data = tile_map.get_cell_tile_data(tile_pos)
		if data:
			friction_coef = data.get_custom_data("friction_coef")
		else:
			friction_coef = 1.0

func apply_slime_trail() -> void:
	if not is_on_floor(): 
		return

	if not slime_map or not tile_map:
		return

	var feet_offset = Vector2(0, (collision_shape_original_size.y / 2) + 2)
	var target_pos = slime_map.local_to_map(slime_map.to_local(global_position + feet_offset))

	if last_tile_pos == Vector2i(-1, -1):
		last_tile_pos = target_pos
		return

	if target_pos != last_tile_pos:
		_place_slime(last_tile_pos)
		last_tile_pos = target_pos

func _place_slime(pos: Vector2i) -> void:
	if tile_map.get_cell_source_id(pos) != -1 and slime_map.get_cell_source_id(pos) == -1:
		var random_tile = Vector2i(randi_range(0, 3), randi_range(0, 1))
		slime_map.set_cell(pos, source_id, random_tile)

func reset_trail_tracking():
	var feet_offset = Vector2(0, (collision_shape_original_size.y / 2) + 2)
	last_tile_pos = slime_map.local_to_map(slime_map.to_local(global_position + feet_offset))
		
func _on_body_entered_hurt_box(_body: Node2D) -> void:
	state_machine.transition_to("DeathState")
	
func _handle_jump_buffer(delta: float) -> void:
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta
	
	if Input.is_action_just_pressed("player_jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME

func _update_grapple_preview() -> void:

	var mouse_pos = get_local_mouse_position()
	var is_crouching = Input.is_action_pressed("player_down")

	# Always clamp the raycast to the maximum range
	var target_direction = mouse_pos.normalized()
	var max_target_pos = target_direction * GRAPPLE_RANGE

	# If the mouse is closer than the max range, use mouse position. 
	# Otherwise, use the boundary of the circle.
	if mouse_pos.length() <= GRAPPLE_RANGE:
		grapple_cast.target_position = mouse_pos
	else:
		grapple_cast.target_position = max_target_pos

	if is_crouching and is_on_floor():
		var slide_assist_angle = deg_to_rad(30) 
		var slide_dir = Vector2(sign(mouse_pos.x), 0).rotated(slide_assist_angle)
		max_target_pos = slide_dir * GRAPPLE_RANGE

	grapple_cast.force_raycast_update()

	var anchor_point = _get_snapped_anchor_point()
	
	if anchor_point != null:
		preview_point = anchor_point
	# 2. If no anchor is nearby, check for Walls/Tiles
	elif grapple_cast.is_colliding():
		preview_point = grapple_cast.get_collision_point()
	# 3. Otherwise, no point
	else:
		preview_point = null

	# Visual feedback for the character
	if GRAPPLE_COUNT > 0:
		animated_sprite.modulate = Color(1, 0, 1)
	else:
		animated_sprite.modulate = Color.WHITE

	queue_redraw()

func _handle_grapple_input() -> void:

	if Input.is_action_just_pressed("player_grapple") and GRAPPLE_COUNT > 0:
		if preview_point != null:
			grapple_point = preview_point
			var collider = grapple_cast.get_collider()
			if collider and collider.has_method("destroy"):
				collider.destroy()
			
			GRAPPLE_COUNT -= 1
			state_machine.transition_to("GrappleState", {"point": preview_point})

func _get_snapped_anchor_point():
	var best_point = null
	var closest_dist_to_line = GRAPPLE_MARGIN

	var line_start = global_position
	var mouse_dir = (get_global_mouse_position() - global_position).normalized()
	var line_end = global_position + (grapple_cast.target_position)

	for anchor in get_tree().get_nodes_in_group("GrappleAnchors"):
		var marker = anchor.find_child("Marker2D", true, false)
		var anchor_pos = marker.global_position if marker else anchor.global_position
		var dist_to_player = global_position.distance_to(anchor_pos)
		if dist_to_player > GRAPPLE_RANGE:
			continue

		var dir_to_anchor = (anchor_pos - global_position).normalized()
		var alignment = mouse_dir.dot(dir_to_anchor)

		if alignment < 0.5: 
			continue
		
		var closest_point_on_line = Geometry2D.get_closest_point_to_segment(anchor_pos, line_start, line_end)
		var dist_to_line = anchor_pos.distance_to(closest_point_on_line)

		if dist_to_line < closest_dist_to_line:
			if _has_line_of_sight(anchor_pos):
				closest_dist_to_line = dist_to_line
				best_point = anchor_pos.snapped(Vector2(1, 1))

	return best_point

func _has_line_of_sight(target_global_pos: Vector2) -> bool:
	var original_target = grapple_cast.target_position
	grapple_cast.target_position = to_local(target_global_pos)
	grapple_cast.force_raycast_update()

	var can_see = !grapple_cast.is_colliding() or \
					grapple_cast.get_collision_point().distance_to(target_global_pos) < 5.0

	grapple_cast.target_position = original_target
	return can_see
			
func _draw() -> void:
	if gravity_disabled and grapple_point != null and not is_on_floor() and not is_on_wall():
		var player_center = Vector2(0, player_center_offset)
		var local_rope_end = to_local(grapple_point)
		draw_line(player_center, local_rope_end, Color(0.5, 1.0, 0.0, 0.7), 1.0)
		draw_circle(local_rope_end, 2.0, Color(0.8, 0.8, 0.8))

	var circle_color = Color(1, 1, 1, 0.3)
	var line_width = 0.5
	var dash_count = 64 
	var dash_length = TAU / (dash_count * 2) 

	for i in range(dash_count):
		var start_angle = i * (TAU / dash_count)
		var end_angle = start_angle + dash_length
		draw_arc(Vector2.ZERO, GRAPPLE_RANGE, start_angle, end_angle, 4, circle_color, line_width)

	draw_set_transform(-global_position, 0, Vector2.ONE)
	if preview_point != null:
		draw_circle(preview_point, 3.0, Color(1, 1, 1, 0.8))

func _collectable_retrieved(collectable: Collectable) -> void:
	if collectable is SlimeOrb:
		print("collected")
		GRAPPLE_COUNT = 1
