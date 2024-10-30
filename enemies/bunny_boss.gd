class_name BunnyBoss
extends "res://enemies/enemy.gd"  # Inherits directly from Enemy

@onready var move_component_2: MoveComponent = $MoveComponent2
@onready var attack_timer: Timer = $AttackTimer  # Timer to control bullet attack intervals
@onready var move_timer: Timer = $MoveTimer  # Timer to control random movement intervals
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var spawner_component_2: SpawnerComponent = $SpawnerComponent2


@export var move_speed: float = 100.0  # Base horizontal movement speed
@export var bullet_speed: float = 300.0  # Speed of the bullets
@export var bullet_count: int = 8  # Number of bullets in the half-circle
@export var split_health_threshold: float = 0.5  # Threshold to trigger splitting (50% of initial health)

var initial_health: int  # Stores the initial health as max reference
var original_position: Vector2
var is_splitting: bool = false
var can_flash: bool = true  # Tracks if the boss can flash

enum State { IDLE, PREPARE_ATTACK, ATTACK, RETURN }
var current_state: State = State.IDLE

# Screen boundaries
var screen_width = ProjectSettings.get_setting("display/window/size/viewport_width")
var screen_margin = 16  # Margin to avoid touching screen edge directly

func _ready() -> void:
	super()
	original_position = global_position
	initial_health = stats_component.health  # Capture initial health as max reference
	
	# Connect health signal to handle boss death
	stats_component.no_health.connect(_on_death)
	
	# Start horizontal movement and set up attack timer
	start_moving()
	attack_timer.timeout.connect(prepare_attack)
	attack_timer.start(3.0)  # Set interval for attack, e.g., every 3 seconds

	# Set up the move timer for random movement intervals
	move_timer.timeout.connect(randomize_movement)
	move_timer.start(2.0)  # Boss will change direction every 2 seconds

func _process(delta: float) -> void:
	# Check health threshold for splitting
	if !is_splitting and stats_component.health <= split_health_threshold * initial_health:
		split_boss()
	match current_state:
		State.IDLE:
			move_randomly(delta)
		State.ATTACK:
			pass  # No movement on x-axis during attack

# Horizontal movement with bounce back at screen edges and random direction
func move_randomly(delta: float) -> void:
	position.x += move_speed * delta

	# Bounce back at screen boundaries
	if position.x < screen_margin:
		position.x = screen_margin  # Stay within bounds
		move_speed = abs(move_speed)  # Move right
		animated_sprite_2d.flip_h = false  # Flip sprite if needed

	elif position.x > screen_width - screen_margin:
		position.x = screen_width - screen_margin  # Stay within bounds
		move_speed = -abs(move_speed)  # Move left
		animated_sprite_2d.flip_h = true  # Flip sprite if needed

# Start moving by setting initial state to IDLE
func start_moving() -> void:
	current_state = State.IDLE
	animated_sprite_2d.play("default")

# Randomize movement direction and speed
func randomize_movement() -> void:
	if current_state == State.IDLE:
		# Randomize speed and direction
		move_speed = randf_range(-150.0, 150.0)  # Random speed in both directions

# Prepare for attack: stop movement and play preparation animation
func prepare_attack() -> void:
	current_state = State.PREPARE_ATTACK
	move_speed = 0  # Stop movement
	animated_sprite_2d.play("attack")  # Play animation for preparation

	# Delay before starting attack
	await get_tree().create_timer(0.5).timeout  # Delay before shooting
	shoot_bullets()

# Shoot bullets in a half-circle using SpawnerComponent
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

# Reset to IDLE state after the attack
func reset_to_idle() -> void:
	current_state = State.IDLE
	animated_sprite_2d.play("default")
	move_speed = 100.0  # Resume movement
	attack_timer.start(3.0)  # Restart attack timer

# Splits the boss into two smaller versions when health is below threshold
func split_boss() -> void:
	is_splitting = true
	stats_component.health = int(initial_health * 0.25)

	# Create a clone with 25% health
	var clone = self.duplicate()
	clone.global_position = global_position + Vector2(100, 0)  # Offset to the side
	clone.set("can_flash", false)  # Disable flashing initially
	get_parent().add_child(clone)

	# Re-enable flash for the clone after some delay
	await get_tree().create_timer(1.0).timeout
	clone.set("can_flash", true)  # Allow flashing after delay

# Handle the boss's death and clean up signals
func _on_death() -> void:
	# Disconnect signals
	attack_timer.disconnect("timeout", prepare_attack)
	move_timer.disconnect("timeout", randomize_movement)
	
	# Any additional cleanup
	queue_free()  # Free the boss from the scene
