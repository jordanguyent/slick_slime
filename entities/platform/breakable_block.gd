extends StaticBody2D

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var detection_area: Area2D = $DetectionArea
@onready var respawn_timer: Timer = $RespawnTimer
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
var tween_loops: int = 30

var break_sound = preload("res://sounds/sfx/apple1.wav")
var respawn_sound = preload("res://sounds/sfx/grass2.wav")

func _ready() -> void:
	respawn_timer.timeout.connect(_on_respawn_timer_timeout)
	sprite.animation_finished.connect(_on_animation_finished)
	sprite.play("default")

func destroy() -> void:
	collision_shape.set_deferred("disabled", true)
	sprite.play("break")
	AudioLoader.play_sfx_2d_deferred(break_sound, "Master", true, global_position, -4)

	if respawn_timer.is_stopped():
		respawn_timer.start()

func _on_respawn_timer_timeout() -> void:
	respawn_timer.stop()
	var space_occupied = false
	for body in detection_area.get_overlapping_bodies():
		if body is Player:
			space_occupied = true
			break
			
	if space_occupied:
		if respawn_timer.time_left <= 1:
			respawn_timer.start(1)
		return
	respawn()

func respawn():
	sprite.play("respawn")
	AudioLoader.play_sfx_2d_deferred(respawn_sound, "Master", true, global_position)

func _on_animation_finished() -> void:
	if sprite.animation == "respawn":
		sprite.play("default")
		collision_shape.set_deferred("disabled", false)
		detection_area.set_deferred("monitoring", true)
