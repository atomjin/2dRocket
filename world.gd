extends Node2D

@export var game_stats: GameStats

@onready var ship: Node2D = $Ship
@onready var score_label: Label = $ScoreLabel 
@onready var world: Node2D = $"."
@onready var pause_menu: Control = $PauseMenu

var paused = false 

func _ready() -> void:
	update_score_label(game_stats.score)
	game_stats.score_changed.connect(update_score_label)
	
	ship.tree_exiting.connect(func():
		await  get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://menus/game_over.tscn")
		)
	
func _process(delta):
	if Input.is_action_just_pressed("pause"):
		pauseMenu()
	
func pauseMenu():
	if paused:
		pause_menu.hide()
		Engine.time_scale = 1
	else:
		pause_menu.show()
		Engine.time_scale = 0
		
	paused = !paused
	
func update_score_label(new_score: int)->void:
	score_label.text = "Score: " + str(new_score)
