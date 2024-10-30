# AnimationComponent.gd
extends Node

@export var delay_before_move: float = 1.0  # Time to wait before starting movement
@onready var delay_timer: Timer = $DelayTimer  # Ensure there is a Timer node named "DelayTimer" in the scene
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D  # Assign the sprite here

signal animation_finished  # Signal to notify when the animation delay is complete

func _ready() -> void:
	if delay_timer:  # Ensure delay_timer is valid before accessing it
		delay_timer.wait_time = delay_before_move
		delay_timer.one_shot = true
		delay_timer.timeout.connect(start_moving_animation)
		delay_timer.start()  # Start the timer immediately on ready
	else:
		push_error("Timer node 'DelayTimer' not found in AnimationComponent")

func start_moving_animation() -> void:
	animated_sprite.play("aggo")  # Replace "moving" with your actual animation name
	emit_signal("animation_finished")
