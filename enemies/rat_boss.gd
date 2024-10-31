class_name RatBoss
extends "res://enemies/enemy.gd"  # Adjust to the actual path of your Enemy base class

@onready var attack_timer: Timer = $AttackTimer  # Timer for attacks
@onready var dash_timer: Timer = $DashTimer  # Timer for dashing
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var spawner_component_2: SpawnerComponent = $SpawnerComponent2  # Bullet spawner for shooting bullets

@export var move_speed: float = 100.0  # Horizontal movement speed
@export var dash_speed: float = 300.0  # Speed for diagonal dash
@export var dash_duration: float = 1.5  # Duration of dash movement
@export var bullet_speed: float = 100.0  # Speed of bullets
@export var bullet_angle_offset: float = PI / 6  # Offset angle for bullet spread

var original_position: Vector2  # Original position to return to after dash
var target_x_position: float  # Random x target for horizontal movement

var initial_health: int
var current_stage = 1  # Start at stage 1

enum Stage { STAGE1, STAGE2, STAGE3 }
enum State { IDLE, PREPARE_ATTACK, ATTACK, PREPARE_DASH, DASH, RETURN }
var current_state: State = State.IDLE

# Screen boundaries
var screen_width = ProjectSettings.get_setting("display/window/size/viewport_width")
var screen_margin = 16  # Margin from screen edge

func _ready() -> void:
	super()
	initial_health = stats_component.health  # Store initial health for reference
	original_position = global_position  # Save the starting position
	pick_new_x_target()  # Pick a random x target within bounds
	start_stage_1()

func _process(delta: float) -> void:
	match current_state:
		State.IDLE:
			move_towards_target_x(delta)
		State.DASH:
			dash_diagonal(delta)
		State.RETURN:
			return_to_position(delta)
	
	update_stage()

# Update stages based on health thresholds
func update_stage() -> void:
	var health_ratio = stats_component.health / initial_health

	if health_ratio <= 0.35 and current_stage == Stage.STAGE2:
		start_stage_3()
	elif health_ratio <= 0.75 and current_stage == Stage.STAGE1:
		start_stage_2()

# Stage 1: Idle, allowing the player to deal damage
func start_stage_1() -> void:
	current_stage = Stage.STAGE1
	current_state = State.IDLE
	animated_sprite_2d.play("menacing")  # Play idle animation
	move_speed = 0  # Boss is stationary in this stage
	attack_timer.start(5.0)

# Stage 2: Enable dashing and shooting
func start_stage_2() -> void:
	current_stage = Stage.STAGE2
	animated_sprite_2d.play("buff")  # Change to buff mode animation
	move_speed = 100.0  # Enable movement
	attack_timer.start(3.0)  # Attack more frequently
	dash_timer.start(5.0)

# Stage 3: Clone the boss into two instances with shared health
func start_stage_3() -> void:
	current_stage = Stage.STAGE3
	animated_sprite_2d.play("buff")
	stats_component.health = int(stats_component.health / 2)  # Split health for clones

	# Create the clone
	var clone = self.duplicate()
	clone.global_position = global_position + Vector2(100, 0)  # Offset clone to the side
	if clone.has_node("StatsComponent"):
		var clone_stats = clone.get_node("StatsComponent") as StatsComponent
		clone_stats.health = stats_component.health  # Shared health
	get_parent().add_child(clone)

# Decide randomly between shooting and dashing in Stage 2 or higher
func decide_action() -> void:
	if current_stage >= Stage.STAGE2:
		if randi() % 2 == 0:
			prepare_attack()
		else:
			prepare_dash()

# Move towards a random x position within bounds
func move_towards_target_x(delta: float) -> void:
	position.x += move_speed * delta * sign(target_x_position - position.x)
	animated_sprite_2d.flip_h = position.x > target_x_position

	# Bounce back if hitting screen edges
	if position.x < screen_margin:
		position.x = screen_margin
		move_speed = abs(move_speed)
	elif position.x > screen_width - screen_margin:
		position.x = screen_width - screen_margin
		move_speed = -abs(move_speed)

	if abs(position.x - target_x_position) < 1.0:
		pick_new_x_target()

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

# Shoot bullets in a fan spread
func shoot_bullets() -> void:
	current_state = State.ATTACK
	animated_sprite_2d.play("attack")

	# Shooting bullets in a fan of three directions
	var angles = [PI / 2 - 0.2, PI / 2, PI / 2 + 0.2]
	for angle in angles:
		var direction = Vector2(cos(angle), sin(angle)).normalized() * bullet_speed
		var bullet_instance = spawner_component_2.spawn(global_position)
		if bullet_instance.has_method("set_direction"):
			bullet_instance.set_direction(direction)
		bullet_instance.rotation = angle

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
	position = position.move_toward(original_position, dash_speed * delta)
	if position.distance_to(original_position) < 1.0:
		position = original_position  # Correct minor offsets
		reset_to_idle()
