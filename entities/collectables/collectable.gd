class_name Collectable extends Area2D

@onready var spawn_timer: Timer = $SpawnTimer
@onready var panel: Panel = $Panel
var spawn_time: float = 3.0

func _ready() -> void:
	spawn_timer.timeout.connect(_on_timer_timeout)
	panel.visible = true

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
	panel.visible = false
	set_deferred("monitoring", false)
	spawn_timer.start(spawn_time)


func _on_timer_timeout() -> void:
	panel.visible = true
	set_deferred("monitoring", true)
