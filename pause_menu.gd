extends Control


@onready var world: Node2D = $".." as Node2D


func _on_resume_pressed() -> void:
	world.pauseMenu()


func _on_quit_pressed() -> void:
	cleanup()
	get_tree().change_scene_to_file("res://stage_selector.tscn")
	world.queue_free()
	
	#ship.queue_free()
	#world.pauseMenu()

func cleanup():
	for child in get_children():
		if child is Node:  # Ensure it's a Node
			child.queue_free()  # Remove the child node from the scene

	print("All nodes cleared from the current scene.")
