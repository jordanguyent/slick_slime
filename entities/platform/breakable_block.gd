extends StaticBody2D

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var detection_area: Area2D = $DetectionArea
@onready var respawn_timer: Timer = $RespawnTimer
@onready var panel = $Panel
var tween_loops: int = 30

func _ready() -> void:
	respawn_timer.timeout.connect(_on_respawn_timer_timeout)

func destroy() -> void:
	collision_shape.set_deferred("disabled", true)
	hide()

	if respawn_timer.is_stopped():
		respawn_timer.start()

func _on_respawn_timer_timeout() -> void:
	var space_occupied = false
	for body in detection_area.get_overlapping_bodies():
		if body is Player:
			space_occupied = true
			break
			
	if space_occupied:
		if respawn_timer.time_left <= 0.5:
			respawn_timer.start(0.5)
		return
		
	respawn()

func respawn():
	collision_shape.set_deferred("disabled", false)
	detection_area.set_deferred("monitoring", true)
	show()
	panel.modulate = Color.WHITE
	panel.position = Vector2.ZERO
