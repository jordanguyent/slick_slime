extends Camera2D

@export var target_path: NodePath
@export var smoothing_speed: float = 8.0
@export var dead_zone_radius: float = 20.0 # Pixels the player can move before camera follows
@export var look_ahead_distance: float = 60.0 # How far ahead to look
@export var look_ahead_speed: float = 2.0    # How fast the camera shifts its focus

@onready var target = get_node(target_path)

var look_ahead_offset: float = 0.0

func _process(delta):
	if target:
		# 1. Determine direction (based on velocity or input)
		var move_dir = 0
		if target.velocity.x > 1: # Moving Right
			move_dir = 1
		elif target.velocity.x < -1: # Moving Left
			move_dir = -1
		
		# 2. Smoothly shift the offset toward the direction we are moving
		var target_offset = move_dir * look_ahead_distance
		look_ahead_offset = lerp(look_ahead_offset, target_offset, look_ahead_speed * delta)
		
		# 3. Apply the offset to the final target position
		var final_target = target.global_position
		final_target.x += look_ahead_offset
		
		# 4. Smoothly move the camera to that final position
		global_position = global_position.lerp(final_target, smoothing_speed * delta)

func update_limits_from_rect(boundary: ReferenceRect):
	var rect_pos = boundary.global_position
	var rect_size = boundary.size

	limit_left = rect_pos.x
	limit_top = rect_pos.y
	limit_right = rect_pos.x + rect_size.x
	limit_bottom = rect_pos.y + rect_size.y