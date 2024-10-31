class_name cow_boss
extends "res://enemies/enemy.gd"  # Adjust to the actual path of your Enemy base class

@onready var attack_timer: Timer = $AttackTimer  # Timer for attacks
@onready var dash_timer: Timer = $DashTimer  # Timer for dashing
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var spawner_component_2: SpawnerComponent = $SpawnerComponent2  # Bullet spawner for shooting bullets

@export var move_speed: float = 100.0  # Horizontal movement speed
@export var dash_speed: float = 300.0  # Speed for diagonal dash
@export var dash_duration: float = 2.5  # Duration of dash movement
@export var bullet_speed: float = 1.0  # Speed of bullets
@export var bullet_angle_offset: float = PI / 6  # Offset angle for bullet spread (30 degrees)

var original_position: Vector2  # Original position to return to after dash
var target_x_position: float  # Random x target for horizontal movement

enum State { IDLE, PREPARE_ATTACK, ATTACK, PREPARE_DASH, DASH, RETURN }
var current_state: State = State.IDLE
var cow_stay: bool = true
# Screen boundaries
var screen_width = ProjectSettings.get_setting("display/window/size/viewport_width")
var screen_margin = 16  # Margin from screen edge

signal boss_defeated
func _ready() -> void:
	super()
	original_position = Vector2(960, 200)   # Save the starting position
	pick_new_x_target()  # Pick a random x target within bounds
	stats_component.no_health.connect(on_boss_defeated)
	# Timer connections
	attack_timer.timeout.connect(decide_action)
	attack_timer.start(3.0)  # Set interval to decide between shooting and dashing

func _process(delta: float) -> void:
	match current_state:
		State.IDLE:
			move_towards_target_x(delta)
		State.DASH:
			dash_diagonal(delta)
		State.RETURN:
			return_to_position(delta)
func on_boss_defeated() -> void:
	emit_signal("boss_defeated")  # Notify main scene
	queue_free()  # Destroy BossSnake instance


# Decide randomly between shooting and dashing
func decide_action() -> void:
	if current_state == State.IDLE:
		var random_choice = randi() % 2  # 0 for attack, 1 for dash
		if random_choice == 0:
			prepare_attack()
		else:
			prepare_dash()

# Move towards a random x position within bounds
func move_towards_target_x(delta: float) -> void:
	if abs(position.x - target_x_position) < 1.0:
		pick_new_x_target()  # Pick new target if close to current
	else:
		position.x += sign(target_x_position - position.x) * move_speed * delta
		animated_sprite_2d.flip_h = position.x > target_x_position

# Pick a new random x target within screen boundaries
func pick_new_x_target() -> void:
	target_x_position = randf_range(screen_margin, screen_width - screen_margin)

# Prepare for attack: stop movement and play attack animation
func prepare_attack() -> void:
	if current_state == State.IDLE:
		current_state = State.PREPARE_ATTACK
		move_speed = 0
		animated_sprite_2d.play("attack")
		await get_tree().create_timer(0.5).timeout  # Delay before shooting
		shoot_bullets()

# Shoot bullets in three directions (left, forward, and right)
# Shoot bullets in three directions, all downward
# Shoot bullets in three directions, all downward with the middle bullet at 90 degrees
# Shoot bullets in three directions, all downward, centered on 180 degrees
# Shoot bullets in a downward arc centered on 180 degrees
func shoot_bullets() -> void:
	current_state = State.ATTACK
	animated_sprite_2d.play("attack")

	# Define the angles for the bullets
	var angles = [
	PI / 2 - 0.2,  # Slightly left of 90 degrees
	PI / 2,        # Straight up (90 degrees)
	PI / 2 + 0.2   # Slightly right of 90 degrees
]


	for angle in angles:
		var direction = Vector2(cos(angle), sin(angle)).normalized() * bullet_speed
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
	move_speed = 100.0  # Resume movement speed
	attack_timer.start(3.0)  # Restart attack timer

# Prepare for dash: stop, play dash preparation animation, then dash diagonally
func prepare_dash() -> void:
	if current_state == State.IDLE:
		current_state = State.PREPARE_DASH
		move_speed = 0
		animated_sprite_2d.play("dash")
		
		await get_tree().create_timer(0.5).timeout  # Delay before dashing
		start_dashing()

# Start diagonal dash
func start_dashing() -> void:
	current_state = State.DASH
	animated_sprite_2d.play("dash")

# Perform diagonal dash (move both x and y directions)
func dash_diagonal(delta: float) -> void:
	position.x += dash_speed * delta * sign(target_x_position - position.x)
	position.y += dash_speed * delta

	if position.y >= original_position.y + dash_speed * dash_duration:
		current_state = State.RETURN
		animated_sprite_2d.play("default")

# Return to original y-position after dash
func return_to_position(delta: float) -> void:
	position.y -= dash_speed * delta

	if position.y <= original_position.y:
		position.y = original_position.y  # Correct minor offsets
		reset_to_idle()  # Resume x-axis movement
