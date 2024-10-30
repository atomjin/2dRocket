extends Node2D

@export var game_stats: GameStats

@onready var ship: Node2D = $Ship
@onready var score_label: Label = $ScoreLabel
@onready var pause_menu: Control = $PauseMenu

var paused = false
var current_score: int = 0  # Track the animated score

func _ready() -> void:
	update_score_label(game_stats.score)  # Initialize the score label
	game_stats.score_changed.connect(animate_score)  # Connect score updates

	ship.tree_exiting.connect(func():
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://menus/game_over.tscn")
	)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		pause_menu_toggle()

	# Update the score label during animation
	score_label.text = "Score: " + str(current_score)

func pause_menu_toggle() -> void:
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
	score_label.text = "Score: " + str(current_score)
