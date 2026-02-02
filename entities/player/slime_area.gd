extends Area2D

static var active_slime_contacts: int = 0

@onready var despawn_timer: Timer = $Timer

func _ready() -> void:
	body_entered.connect(_on_body_entered_area_2d)
	body_exited.connect(_on_body_exited_area_2d)
	despawn_timer.timeout.connect(_on_timer_timeout)


func _on_body_entered_area_2d(_body: Node2D) -> void:
		active_slime_contacts += 1
		_update_slime_state()

func _on_body_exited_area_2d(_body: Node2D) -> void:
		active_slime_contacts -= 1
		_update_slime_state()

func _update_slime_state() -> void:
	if active_slime_contacts > 0:
		Game.slimed.emit(true)
	else:
		Game.slimed.emit(false)

func _on_timer_timeout() -> void:
	queue_free()