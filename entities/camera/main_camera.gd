extends Camera2D

@export var target_path: NodePath
@export var smoothing_speed: float = 8.0
@export var dead_zone_radius: float = 20.0 
@export var look_ahead_distance: float = 60.0 
@export var look_ahead_speed: float = 2.0 
@export var stage_group_path: NodePath = "/root/Level1/StageGroup"

@onready var target = get_node(target_path)
@onready var stage_group = get_node(stage_group_path)

signal stage_changed(new_stage_node: Node2D)

var look_ahead_offset: float = 0.0
var current_stage: Node2D = null
var limit_tween: Tween

func _process(delta: float) -> void:
	if not target:
		return

	check_room_transition()

	var move_dir = 0
	if target.velocity.x > 1:
		move_dir = 1
	elif target.velocity.x < -1:
		move_dir = -1

	# Your look-ahead and lerp logic remains here
	var target_offset = move_dir * look_ahead_distance
	look_ahead_offset = lerp(look_ahead_offset, target_offset, look_ahead_speed * delta)

	var final_target = target.global_position
	final_target.x += look_ahead_offset

	# This is your manual smoothing
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