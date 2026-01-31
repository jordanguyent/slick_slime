extends Node2D

@onready var area_2d: Area2D = $Area2D
var dir: Vector2
var SPEED: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area_2d.body_entered.connect(_on_body_entered)
	var mouse_pos = get_local_mouse_position()
	dir = mouse_pos.normalized()
	
func _physics_process(delta: float) -> void:
	var velocity = dir * SPEED
	position += velocity * delta
	
func _on_body_entered(body: Node2D) -> void:
	print("Objecct Hit")
	queue_free()
