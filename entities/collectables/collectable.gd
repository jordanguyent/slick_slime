class_name Collectable extends Area2D

# we want our game singleton to handle own the signal, like a radio
# tower
#signal collected(collectable: Collectable)

func _ready() -> void:
	body_entered.connect(_on_body_entered_area_2d)

func _on_body_entered_area_2d(_body: Node2D) -> void:
	#collected.emit(self)
	set_deferred("monitoring", false)
	queue_free()
