extends Node2D

@export var game_stats: GameStats

@onready var ship: Node2D = $Ship
@onready var score_label: Label = $ScoreLabel
@onready var pause_menu: Control = $PauseMenu
@onready var new_scene_path: String = "res://stage_selecter.tscn"
@onready var enemy_generator: Node2D = $EnemyGenerator
@onready var laser_hitbox: LaserHitbox = $Ship/LaserHitbox


#@onready var BOSS_SNAKE: String = "res://enemies/cow_boss.tscn"
@onready var BOSS_SNAKE: PackedScene = preload("res://enemies/cow_boss.tscn")
@onready var victory_scene: PackedScene = preload("res://menus/victory.tscn")


"res://projectile/laser.tscn"
var game_over: bool = false

var paused = false
var current_score: int = 0  # Track the animated score
var upgrade_applied: bool = false
var calling_boss_snake: bool = false
var first_star: bool = false
var second_star: bool = false
var third_star: bool = false
signal score_reached_2000
func _ready() :
	
	reset_game()
	game_stats.score = 0
	Engine.time_scale = 1
	update_score_label(game_stats.score)  # Initialize the score label
	game_stats.score_changed.connect(animate_score)  # Connect score updates
	score_reached_2000.connect(laser_hitbox.increase_damage)
		
	ship.tree_exiting.connect(func():
		game_over = true
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://menus/game_over.tscn")
		await get_tree().create_timer(1.5).timeout
		score_label.hide()
	)
	
	
#	BOSS_SNAKE.tree_exiting.connect(func():
#		pass
		
#	)
		
func _process(delta: float) -> void:
	if not upgrade_applied and current_score >= 2000:
		score_reached_2000.emit()
		upgrade_applied = true
		print()
	if Input.is_action_just_pressed("pause"):
		pause_menu_toggle()
		
	if not calling_boss_snake and current_score >= 4000:
		spawn_boss()
		calling_boss_snake = true
		print("BossCow instantiated!")
	if not first_star and current_score >= 10000:
		first_star = true
		print("your score right now is 10,000 and you receive 1 star")
	if not second_star and current_score >= 12000:
		second_star = true
		print("your score right now is 12,000 and you receive 1 star")
	if not third_star and current_score >= 15000:
		third_star = true
		print("your score right now is 15,000 and you receive 1 star")
		
		
	# Update the score label during animation
	score_label.text = "Score: " + str(current_score)

func spawn_boss():
	var boss_snake_instance = BOSS_SNAKE.instantiate()  # Directly instantiate the scene
	add_child(boss_snake_instance)
	boss_snake_instance.position = Vector2(960, 200)
	print("BossSnake instantiated!")
	boss_snake_instance.boss_defeated.connect(on_boss_defeated)
	
func on_boss_defeated() -> void:
	print("Victory! Boss defeated.")
	await get_tree().create_timer(1.0).timeout
	ship.hide()
	Engine.time_scale = 0
	get_tree().change_scene_to_file("res://menus/victory.tscn")
	await get_tree().create_timer(1.5).timeout
	score_label.hide()
		
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
func update_score_label(new_score: int):
	current_score = new_score
	score_label.text = "Score : " + str(current_score)
	
func reset_game() -> void:
	paused = false
	game_over = false
	current_score = 0  # Reset score if needed
	update_score_label(current_score)
	
