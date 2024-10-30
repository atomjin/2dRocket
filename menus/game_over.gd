extends Control


@onready var new_scene_path: String = "res://stage_selecter.tscn"
@onready var score_label: Label = $ScoreLabel

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		#clear_scene()
		#ScoreLabel.hide()
		#await get_tree().create_timer(0.1).timeout
		get_tree().change_scene_to_file("res://stage_selecter.tscn")
		
