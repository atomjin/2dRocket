extends Control


@onready var world: Node2D = $".." as Node2D



func _on_resume_pressed() -> void:
	world.pauseMenu()


func _on_quit_pressed() -> void:
	get_tree().quit()
