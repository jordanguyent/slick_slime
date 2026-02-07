class_name Collectable extends Area2D

@onready var spawn_timer: Timer = $SpawnTimer
@onready var panel: Panel = $Panel
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
var spawn_time: float = 3.0

var break_sound = preload("res://sounds/sfx/glass.wav")
var respawn_sound = preload("res://sounds/sfx/grass1.wav")

func _ready() -> void:
	spawn_timer.timeout.connect(_on_timer_timeout)
	sprite.animation_finished.connect(_on_animation_finished)
	panel.visible = false
	sprite.visible = true
	sprite.play("idle")

func _physics_process(_delta: float) -> void:
	if not monitoring:
		return
	
	for body in get_overlapping_bodies():
		if body is Player:
			if body.GRAPPLE_COUNT < body.GRAPPLE_COUNT_MAX:
				collect_item(body)
				break 

func collect_item(_body: Node2D) -> void:
	Game.collected.emit(self)
	panel.visible = true
	sprite.play("eaten")
	AudioLoader.play_sfx_2d_deferred(break_sound, "Master", true, global_position)
	set_deferred("monitoring", false)
	spawn_timer.start(spawn_time)


func _on_timer_timeout() -> void:
	panel.visible = false
	spawn_timer.stop()
	sprite.play("respawn")

func _on_animation_finished() -> void:
	if sprite.animation == "respawn":
		sprite.play("idle")
		set_deferred("monitoring", true) 
