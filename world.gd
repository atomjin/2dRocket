extends Node2D

@export var game_stats: GameStats

@onready var ship: Node2D = $Ship
@onready var score_label: Label = $ScoreLabel
@onready var pause_menu: Control = $PauseMenu
@onready var new_scene_path: String = "res://stage_selecter.tscn"
@onready var enemy_generator: Node2D = $EnemyGenerator


var game_over: bool = false
var paused = false


var current_score: int = 0  # Track the animated score

func _ready() -> void:
	pass
	reset_game()
	game_stats.score = 0
	Engine.time_scale = 1
	update_score_label(game_stats.score)  # Initialize the score label
	game_stats.score_changed.connect(animate_score)  # Connect score updates

	ship.tree_exiting.connect(func():
		game_over = true
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://menus/game_over.tscn")
		await get_tree().create_timer(60.0).timeout
		score_label.hide()
	)

func stop_all_nodes():
	
	print("Stop all")
	
func stop_enemy_spawning() -> void:
	if enemy_generator.is_connected("enemy_spawned", Callable(self, "_on_enemy_spawned")):
		enemy_generator.disconnect("enemy_spawned", Callable(self, "_on_enemy_spawned"))
		print("Enemy spawning stopped.")

func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("pause"):
		pause_menu_toggle()

	# Update the score label during animation
	score_label.text = "Score: " + str(current_score)



func pause_menu_toggle() -> void:
	if game_over:
		
		return
	if paused:
		pause_menu.hide()
		Engine.time_scale = 1
	else:
		pause_menu.show()
		Engine.time_scale = 0

	paused = !paused  # Toggle pause state

# Animate the score smoothly using Tweener API
func animate_score(new_score: int) -> void:
	# Create a Tweener
	var tween = get_tree().create_tween()

	# Animate the 'current_score' property towards the new value
	tween.tween_property(self, "current_score", new_score, 0.5)
	tween.set_ease(Tween.EASE_OUT)  # Set easing after defining the tween

# Update the score instantly if needed
func update_score_label(new_score: int) -> void:
	current_score = new_score
	score_label.text = "Score : " + str(current_score)
	
func reset_game() -> void:
	paused = false
	game_over = false
	current_score = 0  # Reset score if needed
	update_score_label(current_score)
	
