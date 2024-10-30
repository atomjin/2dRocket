# MoveToPlayerComponent.gd
extends Node

@export var move_speed: float = 100.0
@export var target: Node2D  # Assign the player here in the editor or via script

var moving: bool = false

func start_moving() -> void:
	moving = true

func stop_moving() -> void:
	moving = false

func _process(delta: float) -> void:
	if moving and target:
		var direction = (target.global_position - get_parent().global_position).normalized()
		get_parent().position += direction * move_speed * delta
