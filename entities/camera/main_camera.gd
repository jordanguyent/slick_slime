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

func _process(delta):
	if not target:
		return

	check_room_transition()

	var move_dir = 0
	if target.velocity.x > 1:
		move_dir = 1
	elif target.velocity.x < -1:
		move_dir = -1
	
	var target_offset = move_dir * look_ahead_distance
	look_ahead_offset = lerp(look_ahead_offset, target_offset, look_ahead_speed * delta)
	

	var final_target = target.global_position
	final_target.x += look_ahead_offset

	global_position = global_position.lerp(final_target, smoothing_speed * delta)

func check_room_transition():
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

func update_limits_from_rect(boundary: ReferenceRect):
	var rect_pos = boundary.global_position
	var rect_size = boundary.size

	# If there's an ongoing transition, kill it to start the new one
	if limit_tween:
		limit_tween.kill()

	limit_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	var duration = 0.8 

	limit_tween.tween_property(self, "limit_left", int(rect_pos.x), duration)
	limit_tween.tween_property(self, "limit_top", int(rect_pos.y), duration)
	limit_tween.tween_property(self, "limit_right", int(rect_pos.x + rect_size.x), duration)
	limit_tween.tween_property(self, "limit_bottom", int(rect_pos.y + rect_size.y), duration)