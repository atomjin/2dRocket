class_name SpawnerComponent
extends Node2D

@export var scene: PackedScene

func spawn(global_spawn_position: Vector2 = Vector2.ZERO, parent: Node = null) -> Node:
	# Check if the scene has been set correctly
	assert(scene is PackedScene, "Error: The scene export was never set on this spawner component.")

	# Use the provided parent or fall back to the current scene or root node
	if parent == null:
		parent = get_tree().current_scene
		if parent == null:
			parent = get_tree().root  # Fall back to the root node

	# Ensure the parent is still valid
	assert(parent != null, "Error: No valid parent found to add the instance.")

	# Instance the scene
	var instance = scene.instantiate()
	
	# Add the instance as a child of the parent
	parent.add_child(instance)

	# Update the global position of the instance
	instance.global_position = global_spawn_position

	# Return the instance for further operations
	return instance
