extends Node2D

@export var speed: float = 300.0
var direction: Vector2 = Vector2.ZERO

# Function to set the direction
func set_direction(new_direction: Vector2) -> void:
	direction = new_direction

# Move the bullet each frame
func _process(delta: float) -> void:
	position += direction * speed * delta
