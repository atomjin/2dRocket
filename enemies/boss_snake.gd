extends "res://enemies/enemy.gd"



func _ready() -> void:
	super()
	move_component.velocity.x = 80
