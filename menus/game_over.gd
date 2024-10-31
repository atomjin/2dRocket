extends Control

@onready var new_scene_path: String = "res://stage_selecter.tscn"
@onready var score_label: Label = $ScoreLabel



func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
#		if boss_snake:
#			boss_snake.queue_free()  # This removes the boss snake node
#			print("Boss snake removed!")
		
		# Optionally hide the score label or clear scene if needed
		# clear_scene()
		# score_label.hide()
		# await get_tree().create_timer(0.1).timeout

		# Change to the stage selector scene
		get_tree().change_scene_to_file(new_scene_path)
