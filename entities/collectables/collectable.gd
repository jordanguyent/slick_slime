class_name Collectable extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered_area_2d)

func _on_body_entered_area_2d(_body: Node2D) -> void:
	Game.collected.emit(self)
	set_deferred("monitoring", false)
	queue_free()
