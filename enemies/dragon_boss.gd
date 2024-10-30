class_name DragonBoss
extends "res://enemies/enemy.gd"  # Adjust the path to your base Enemy class

@onready var dash_timer: Timer = $DashTimer  # Timer to control dash attack intervals
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@export var move_speed: float = 100.0  # Speed to move towards random x positions
@export var dash_speed: float = 500.0  # Speed of the vertical dash
@export var dash_duration: float = 1.5  # Duration of the dash in seconds
@export var return_duration: float = 0.5  # Duration to return to the original position

var original_position: Vector2
var target_x_position: float
var is_dashing: bool = false

enum State { IDLE, PREPARE_DASH, DASH, RETURN }
var current_state: State = State.IDLE

# Screen boundaries
var screen_width = ProjectSettings.get_setting("display/window/size/viewport_width")
var screen_margin = 64  # Margin to avoid touching the screen edge directly

func _ready() -> void:
	# Save the starting position to return to after the dash
	super()
	original_position = global_position

	# Start random x movement and set up dash timer
	pick_new_x_target()
	dash_timer.timeout.connect(prepare_dash)
	dash_timer.start(3.0)  # Set the interval for the dash attack, e.g., every 3 seconds

func _process(delta: float) -> void:
	match current_state:
		State.IDLE:
			# Move towards the random x target if in IDLE state
			move_towards_target_x(delta)
		State.DASH:
			# Move vertically during the dash
			dash_downward(delta)
		State.RETURN:
			# Move vertically back to the original position
			return_to_position(delta)

# Move towards a random x position
func move_towards_target_x(delta: float) -> void:
	if abs(position.x - target_x_position) < 1.0:
		# If close to the target, pick a new x position
		pick_new_x_target()
	else:
		# Move towards the target x position
		position.x += sign(target_x_position - position.x) * move_speed * delta

	# Optional: Flip the sprite based on movement direction
	animated_sprite_2d.flip_h = position.x > target_x_position

# Pick a new random target x position within screen boundaries
func pick_new_x_target() -> void:
	target_x_position = randf_range(screen_margin, screen_width - screen_margin)

# Prepare to dash: stop horizontal movement and play the dash preparation animation
func prepare_dash() -> void:
	# Only initiate dash if in IDLE state to prevent repeated attacks
	if current_state == State.IDLE:
		current_state = State.PREPARE_DASH
		animated_sprite_2d.play("attack")  # Play an animation to prepare for the dash

		# Wait a moment, then start dashing
		await get_tree().create_timer(0.5).timeout  # Delay before dashing
		start_dashing()

# Start the dash downward
func start_dashing() -> void:
	current_state = State.DASH
	animated_sprite_2d.play("attack")
	is_dashing = true

# Perform the dash movement
func dash_downward(delta: float) -> void:
	position.y += dash_speed * delta

	# Check if the dash duration has passed, then switch to return state
	if position.y >= original_position.y + dash_speed * dash_duration:
		current_state = State.RETURN
		animated_sprite_2d.play("default")

# Return to the original position after the dash
func return_to_position(delta: float) -> void:
	var distance_to_move = (original_position.y - position.y) / return_duration * delta
	position.y += distance_to_move

	# When back to the original position, reset to IDLE
	if abs(position.y - original_position.y) < 1.0:
		position.y = original_position.y  # Correct any small offsets
		is_dashing = false
		reset_to_idle()  # Set to IDLE and resume random x movement

# Reset to IDLE state and restart the dash timer
func reset_to_idle() -> void:
	current_state = State.IDLE
	animated_sprite_2d.play("default")
	pick_new_x_target()  # Pick a new x target to move to
	dash_timer.start(3.0)  # Restart the dash timer
