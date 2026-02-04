extends Area2D

@onready var spawn_point: Marker2D = $Marker2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(_body: Node2D) -> void:
	var level = get_tree().current_scene
	level.set_checkpoint(spawn_point.global_position)