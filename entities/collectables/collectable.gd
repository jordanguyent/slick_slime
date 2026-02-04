class_name Collectable extends Area2D

@onready var spawn_timer: Timer = $SpawnTimer
@onready var panel: Panel = $Panel
var spawn_time: float = 3.0

func _ready() -> void:
	body_entered.connect(_on_body_entered_area_2d)
	spawn_timer.timeout.connect(_on_timer_timeout)
	panel.visible = true
	

func _on_body_entered_area_2d(_body: Node2D) -> void:
	Game.collected.emit(self)
	panel.visible = false
	set_deferred("monitoring", false)
	spawn_timer.start(spawn_time)
	

func _on_timer_timeout() -> void:
	panel.visible = true
	set_deferred("monitoring", true)
