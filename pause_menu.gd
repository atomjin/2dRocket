extends Control


@onready var world: Node2D = $".." as Node2D
@onready var new_scene_path: String = "res://stage_selector.tscn"

func _on_resume_pressed() -> void:
	world.pause_menu_toggle()


func _on_quit_pressed() -> void:
	if world.game_over:
		change_scene("res://menus/main_menu.tscn")
	else:
		change_scene()
	

func change_scene(scene_path: String = ""):
	if scene_path == "":
		scene_path = new_scene_path
	
	var root = get_tree().root
	for child in root.get_children():
		child.queue_free()
	
	var new_scene=load(new_scene_path).instantiate()
	root.add_child(new_scene)
