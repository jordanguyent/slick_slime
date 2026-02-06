class_name LevelOne extends Node2D

@onready var stage_group: Node2D = $StageGroup
@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $MainCamera 
@onready var level_ui: CanvasLayer = $CanvasLayer
var current_spawn_point: Vector2 

@export var current_stage = 0
var stage_list: Array
var DEBUG: bool = true


var stage_spawn_list: Array = [
	Vector2(16, 152),			# start stage
	Vector2(1056.0, 152),		# stage 1
	Vector2(1376.0, 152),		# stage 1.5
	Vector2(1840.0, 152),		# stage 2
	Vector2(2480.0, 152),		# stage 3
	Vector2(3112.0, 56),		# stage 4
	Vector2(3760.0, 152), 		# stage 5
	Vector2(4400.0, 72), 		# stage 6
	Vector2(4376.0, -152.0), 	# stage 7
	Vector2(4048.0, -152.0), 	# stage 7.5
	Vector2(4400.0, -360.0), 	# stage 8
	Vector2(4720.0, -360.0),	# stage 9
	Vector2(5352.0, -296.0), 	# Stage 10
	Vector2(6632.0, -192.0),	# Stage 11
	Vector2(7192.0, -64.0),     # Stage 12
]

func _ready() -> void:
	current_spawn_point = player.position
	stage_list = stage_group.get_children()

	if camera.has_signal("stage_changed"):
		camera.stage_changed.connect(_on_camera_stage_changed)

	inject_tilemap_to_player()

func _process(_delta: float) -> void:
	if DEBUG:
		if Input.is_action_just_pressed("next_stage"):
			if current_stage < stage_list.size() - 1:
				current_stage += 1
				player.position = stage_spawn_list[current_stage]
		if Input.is_action_just_pressed("prev_stage"):
			if current_stage > 0:
				current_stage -= 1
				player.position = stage_spawn_list[current_stage]

func switch_to_stage(index: int) -> void:
	if index >= 0 and index < stage_list.size():
		current_stage = index
		inject_tilemap_to_player()
	else:
		push_error("Stage index out of bounds!")

func inject_tilemap_to_player() -> void:
	var stage = stage_list[current_stage]

	var base_map = stage.find_child("BaseTileLayer", true, false)
	var slime_map = stage.find_child("SlimeTileLayer", true, false)

	if player:
		if base_map:
			player.tile_map = base_map
		if slime_map:
			player.slime_map = slime_map

func set_checkpoint(pos: Vector2) -> void:
	current_spawn_point = pos

func respawn_player():
	if player:
		player.global_position = current_spawn_point
		player.velocity = Vector2.ZERO
		player.is_alive = true

func _on_camera_stage_changed(new_stage_node: Node2D):
	# Find the index of the stage node the camera just found
	var index = stage_list.find(new_stage_node)
	if index != -1:
		current_stage = index
		inject_tilemap_to_player()
		print("TileMap updated for stage: ", new_stage_node.name)
