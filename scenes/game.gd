extends Node2D

@warning_ignore("unused_signal")
signal collected(collectable: Collectable)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_fullscreen"): # Define this in Input Map
		toggle_fullscreen()
	if event.is_action_pressed("game_quit"):
		get_tree().quit()

func toggle_fullscreen():
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)