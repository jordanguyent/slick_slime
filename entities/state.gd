class_name State extends Node2D

var player: CharacterBody2D
var state_machine: StateController

func enter(_msg: Dictionary = {}) -> void:
	pass

func exit() -> void:
	pass
	
func handle_input(_event: InputEvent) -> void:
	pass
	
func physics_update(_delta: float) -> void:
	pass
