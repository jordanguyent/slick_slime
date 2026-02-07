extends StaticBody2D

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var detection_area: Area2D = $DetectionArea
@onready var break_timer: Timer = $BreakTimer
@onready var respawn_timer: Timer = $RespawnTimer
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
var tween_loops: int = 30

func _ready() -> void:
	detection_area.body_entered.connect(_on_body_entered_area)
	break_timer.timeout.connect(_on_break_timer_timeout)
	respawn_timer.timeout.connect(_on_respawn_timer_timeout)
	sprite.animation_finished.connect(_on_animation_finished)
	sprite.play("default")
	

func _on_body_entered_area(body: Node2D) -> void:
	if body.is_on_floor():
		start_breaking()

func start_breaking() -> void:
	if break_timer.is_stopped(): 
		break_timer.start()
		
		var tween = create_tween().set_loops(tween_loops)
		tween.tween_property(sprite, "position:x", 2.0, 0.05).as_relative()
		tween.tween_property(sprite, "position:x", -2.0, 0.05).as_relative()

func _on_break_timer_timeout():
	break_timer.stop()
	collision_shape.set_deferred("disabled", true)
	detection_area.set_deferred("monitoring", false)
	sprite.play("break")

	if respawn_timer.is_stopped():
		respawn_timer.start()

func _on_respawn_timer_timeout() -> void:
	respawn_timer.stop()
	respawn()

func respawn():
	sprite.play("respawn")

func _on_animation_finished() -> void:
	if sprite.animation == "respawn":
		sprite.play("default")
		collision_shape.set_deferred("disabled", false)
		detection_area.set_deferred("monitoring", true)
