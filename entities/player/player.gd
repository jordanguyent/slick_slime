extends CharacterBody2D

@export_group("Movement Settings")
@export var SPEED = 150.0
@export var ACCELERATION = 1000.0
@export var FRICTION = 1000.0
@export var GRAVITY = 900.0
@export var JUMP_VELOCITY = -300.0
@export var TERMINAL_VELOCITY = 400.0

@export_group("Grapple Settings")
@export var grapple_pull_strength: float = 500.0
@export var grapple_max_speed: float = 800.0
@export var grapple_swing_friction: float = 0.98

# SHould basic movement be implmented here. 
