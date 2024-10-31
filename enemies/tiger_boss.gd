class_name TigerBoss
extends "res://enemies/enemy.gd"  # Inherits from Enemy

@onready var attack_timer: Timer = $AttackTimer  # Timer for bullet attacks
@onready var dash_timer: Timer = $DashTimer  # Timer for dashing
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var spawner_component_2: SpawnerComponent = $SpawnerComponent2

@export var move_speed: float = 100.0  # Horizontal movement speed
@export var dash_speed: float = 500.0  # Speed of the vertical dash
@export var dash_duration: float = 1.5  # Duration of dash movement
@export var bullet_speed: float = 100  # Speed of bullets
@export var bullet_count: int = 8  # Number of bullets in half-circle

var original_position: Vector2  # Stores initial position for return after dash
var target_x_position: float  # Random x target for movement
var dash_elapsed: float = 0.0  # Tracks time during dash

enum State { IDLE, PREPARE_ATTACK, ATTACK, PREPARE_DASH, DASH, RETURN }
var current_state: State = State.IDLE

# Screen boundaries
var screen_width = ProjectSettings.get_setting("display/window/size/viewport_width")
var screen_margin = 64  # Margin from screen edge

func _ready() -> void:
	super()
	original_position = global_position  # Set original position
	pick_new_x_target()  # Initialize a random x position target

	# Timer connections
	attack_timer.timeout.connect(decide_action)
	attack_timer.start(2.0)  # Interval to decide between shoot and dash

func _process(delta: float) -> void:
	match current_state:
		State.IDLE:
			move_towards_target_x(delta)
		State.DASH:
			dash_downward(delta)
		State.RETURN:
			return_to_position(delta)

# Choose an action at random: either prepare to attack or dash
func decide_action() -> void:
	if current_state == State.IDLE:
		var random_choice = randi() % 2  # 0 for attack, 1 for dash
		if random_choice == 0:
			prepare_attack()
		else:
			prepare_dash()

# Move randomly within x-axis bounds and flip sprite direction
func move_towards_target_x(delta: float) -> void:
	if abs(position.x - target_x_position) < 1.0:
		pick_new_x_target()  # Pick new target if close to current
	else:
		position.x += sign(target_x_position - position.x) * move_speed * delta
		animated_sprite_2d.flip_h = position.x > target_x_position

# Choose a new random x target within screen boundaries
func pick_new_x_target() -> void:
	target_x_position = randf_range(screen_margin, screen_width - screen_margin)

# Prepare for attack: stop movement, play attack animation, and delay before shooting
func prepare_attack() -> void:
	if current_state == State.IDLE:
		current_state = State.PREPARE_ATTACK
		move_speed = 0
		animated_sprite_2d.play("attack")
		await get_tree().create_timer(0.5).timeout
		shoot_bullets()

# Shoot bullets in a half-circle pattern
func shoot_bullets() -> void:
	current_state = State.ATTACK
	animated_sprite_2d.play("attack")
	
	# Calculate angle spread for a rightward-facing half-circle
	var start_angle = 0  # 0 degrees, facing right
	var angle_increment = PI / (bullet_count - 1)  # Spread bullets over 180 degrees

	for i in range(bullet_count):
		var angle = start_angle + angle_increment * i
		var direction = Vector2(cos(angle), sin(angle)).normalized()  # Calculate direction for each bullet
		var bullet_instance = spawner_component_2.spawn(global_position)
		
		# Set the direction if using Node2D bullets
		if bullet_instance.has_method("set_direction"):
			bullet_instance.set_direction(direction)
		
		# Rotate bullet to face its movement direction
		bullet_instance.rotation = angle

	# End attack and return to idle state after delay
	await get_tree().create_timer(1.0).timeout  # Duration of attack animation
	reset_to_idle()

# Reset to IDLE state and restart timers
func reset_to_idle() -> void:
	current_state = State.IDLE
	animated_sprite_2d.play("default")
	move_speed = 100.0  # Reset movement speed
	attack_timer.start(2.0)  # Restart attack timer

# Prepare for dash: stop and play dash preparation animation
func prepare_dash() -> void:
	if current_state == State.IDLE:
		current_state = State.PREPARE_DASH
		move_speed = 0
		animated_sprite_2d.play("dash")
		await get_tree().create_timer(0.5).timeout  # Delay before dashing
		start_dashing()

# Start vertical dash
func start_dashing() -> void:
	current_state = State.DASH
	animated_sprite_2d.play("dash")
	dash_elapsed = 0.0  # Reset dash timer

# Perform vertical dash
func dash_downward(delta: float) -> void:
	dash_elapsed += delta
	position.y += dash_speed * delta

	if dash_elapsed >= dash_duration:
		current_state = State.RETURN
		animated_sprite_2d.play("default")

# Return to original y-position after dash
func return_to_position(delta: float) -> void:
	position.y -= dash_speed * delta

	if position.y <= original_position.y:
		position.y = original_position.y  # Correct minor offsets
		reset_to_idle()  # Resume x-axis movement
