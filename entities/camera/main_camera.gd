extends Camera2D

@export var target_path: NodePath
@export var smoothing_speed: float = 8.0
@export var dead_zone_radius: float = 20.0 
@export var look_ahead_distance: float = 80.0 
@export var look_ahead_speed: float = 0.5 
@export var stage_group_path: NodePath = "/root/Level1/StageGroup"
@export var return_delay: float = 2 # Seconds to wait before centering
var stop_timer: float = 0.0

@onready var target = get_node(target_path)
@onready var stage_group = get_node(stage_group_path)

signal stage_changed(new_stage_node: Node2D)

var look_ahead_offset: float = 0.0
var current_stage: Node2D = null
var limit_tween: Tween
var is_cinematic: bool = false
var move_dir = 0

func _process(delta: float) -> void:
	if not target:
		return

	check_room_transition()

	var final_target = target.global_position

	if not is_cinematic:

		if target.velocity.x > 1: 
			move_dir = 1
			stop_timer = return_delay
		elif target.velocity.x < -1: 
			move_dir = -1
			stop_timer = return_delay 
		else:
			if stop_timer > 0:
				stop_timer -= delta
			else:
				move_dir = 0

		var target_offset = move_dir * look_ahead_distance
		look_ahead_offset = lerp(look_ahead_offset, target_offset, look_ahead_speed * delta)
		final_target.x += look_ahead_offset
	else:
		look_ahead_offset = lerp(look_ahead_offset, 0.0, look_ahead_speed * delta)

	global_position = global_position.lerp(final_target, smoothing_speed * delta)

func check_room_transition() -> void:
	if not stage_group:
		return

	for stage in stage_group.get_children():
		var boundary = stage.find_child("CameraBoundary", false)
		
		if boundary and boundary is ReferenceRect:
			var rect = boundary.get_global_rect()
			
			if rect.has_point(target.global_position):
				if current_stage != stage:
					current_stage = stage
					update_limits_from_rect(boundary)
					stage_changed.emit(stage)
				return 
		else:
			push_warning("Stage '" + stage.name + "' is missing a ReferenceRect named 'Boundary'")

func update_limits_from_rect(boundary: ReferenceRect) -> void:
	var rect_pos = boundary.global_position
	var rect_size = boundary.size

	# 1. Kill any existing transition
	if limit_tween:
		limit_tween.kill()

	# 2. Update limits INSTANTLY
	# This avoids the 'squeezing' effect that causes the lock.
	limit_left = int(rect_pos.x)
	limit_top = int(rect_pos.y)
	limit_right = int(rect_pos.x + rect_size.x)
	limit_bottom = int(rect_pos.y + rect_size.y)

	# 3. Use a Tween to smoothly slide the camera position itself
	# This overrides the 'smoothing_speed' logic temporarily for a perfect transition
	limit_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	# Calculate where the camera SHOULD be in the new room
	var target_pos = target.global_position 

	# Tween the camera's global_position to the player's position in the new room
	limit_tween.tween_property(self, "global_position", target_pos, 0.8)

func zoom_to(new_target: Node2D, zoom_val: float) -> void:
	is_cinematic = true
	target = new_target
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "zoom", Vector2(zoom_val, zoom_val), 1.0)

func reset_zoom(player_ref: Node2D) -> void:
	target = player_ref
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "zoom", Vector2(1.0, 1.0), 1.0)
	# Wait for the tween to finish before re-enabling look-ahead
	await tween.finished
	is_cinematic = false
