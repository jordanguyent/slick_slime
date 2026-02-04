class_name LevelOne extends Node2D

@onready var stage_group: Node2D = $StageGroup
@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $MainCamera 
var current_spawn_point: Vector2 

var stage_list: Array
@export var current_stage = 0

func _ready() -> void:
	current_spawn_point = player.position
	
	stage_list = stage_group.get_children()
	inject_tilemap_to_player()

func inject_tilemap_to_player() -> void:
	if stage_list.size() > current_stage:
		var stage = stage_list[current_stage]
		
		# We use a loop to find the nodes by their "Class"
		for child in stage.get_children():
			# 1. Look for the TileMapLayer
			if child is TileMapLayer:
				if player: 
					player.tile_map = child
			
			# 2. Look for the ReferenceRect (Camera Boundary)
			elif child is ReferenceRect:
				if camera: 
					camera.update_limits_from_rect(child)
		
		print("Level: Successfully injected Stage ", current_stage)

func set_checkpoint(pos: Vector2) -> void:
	current_spawn_point = pos

func respawn_player():
	if player:
		player.global_position = current_spawn_point
		player.velocity = Vector2.ZERO
