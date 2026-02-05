class_name LevelOne extends Node2D

@onready var stage_group: Node2D = $StageGroup
@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $MainCamera 
@onready var level_ui: CanvasLayer = $CanvasLayer
var current_spawn_point: Vector2 

var stage_list: Array
@export var current_stage = 0

func _ready() -> void:
	current_spawn_point = player.position
	stage_list = stage_group.get_children()

	if camera.has_signal("stage_changed"):
		camera.stage_changed.connect(_on_camera_stage_changed)

	inject_tilemap_to_player()

func switch_to_stage(index: int) -> void:
	if index >= 0 and index < stage_list.size():
		current_stage = index
		inject_tilemap_to_player()
	else:
		push_error("Stage index out of bounds!")

func inject_tilemap_to_player() -> void:
	var stage = stage_list[current_stage]

	# Reset these to ensure we don't hold old references
	var found_map: TileMapLayer = null

	for child in stage.get_children():
		if child is TileMapLayer:
			found_map = child
			break # Stop at the first one found

	if player and found_map:
		player.tile_map = found_map
	else:
		push_warning("Could not find TileMapLayer in stage: ", stage.name)

func set_checkpoint(pos: Vector2) -> void:
	current_spawn_point = pos

func respawn_player():
	if player:
		player.global_position = current_spawn_point
		player.velocity = Vector2.ZERO

func _on_camera_stage_changed(new_stage_node: Node2D):
	# Find the index of the stage node the camera just found
	var index = stage_list.find(new_stage_node)
	if index != -1:
		current_stage = index
		inject_tilemap_to_player()
		print("TileMap updated for stage: ", new_stage_node.name)
