class_name DragonBoss
extends "res://enemies/enemy.gd"  # Adjust the path to your base Enemy class

@onready var move_component_2: MoveComponent = $MoveComponent2
@onready var dash_timer: Timer = $DashTimer  # Timer to control dash attack intervals
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@export var move_speed: float = 100.0  # Horizontal movement speed
@export var dash_speed: float = 500.0  # Speed of the vertical dash
@export var dash_duration: float = 0.5  # Duration of the dash in seconds
@export var return_duration: float = 0.5  # Duration to return to the original position

var original_position: Vector2
var is_dashing: bool = false

enum State { IDLE, PREPARE_DASH, DASH, RETURN }
var current_state: State = State.IDLE

# Screen boundaries
var screen_width = ProjectSettings.get_setting("display/window/size/viewport_width")
var screen_margin = 16  # Margin to avoid touching the screen edge directly

func _ready() -> void:
	# Save the starting position to return to after the dash
	original_position = global_position

	# Start horizontal movement and set up dash timer
	start_moving()
	dash_timer.timeout.connect(prepare_dash)
	dash_timer.start(3.0)  # Set the interval for the dash attack, e.g., every 3 seconds

func _process(delta: float) -> void:
	match current_state:
		State.IDLE:
			# Move horizontally if in IDLE state
			move_horizontally(delta)
		State.DASH:
			# Move vertically during the dash
			dash_downward(delta)
		State.RETURN:
			# Move vertically back to the original position
			return_to_position(delta)

# Horizontal movement along the x-axis with bounce back when reaching edges
func move_horizontally(delta: float) -> void:
	# Move the boss horizontally
	position.x += move_speed * delta

	# Bounce back if reaching the screen boundaries
	if position.x < screen_margin:
		position.x = screen_margin  # Ensure it stays within bounds
		move_speed = abs(move_speed)  # Move right
		animated_sprite_2d.flip_h = false  # Flip the sprite if needed

	elif position.x > screen_width - screen_margin:
		position.x = screen_width - screen_margin  # Ensure it stays within bounds
		move_speed = -abs(move_speed)  # Move left
		animated_sprite_2d.flip_h = true  # Flip the sprite if needed

# Start moving by setting initial state to IDLE
func start_moving() -> void:
	current_state = State.IDLE
	animated_sprite_2d.play("idle")
	move_component.velocity.x = move_speed

# Prepare to dash: stop horizontal movement and play the dash preparation animation
func prepare_dash() -> void:
	current_state = State.PREPARE_DASH
	move_component.velocity.x = 0  # Stop horizontal movement
	animated_sprite_2d.play("prepare_dash")  # Play an animation to prepare for the dash

	# Wait a moment, then start dashing
	await get_tree().create_timer(0.5).timeout  # Delay before dashing
	start_dashing()

# Start the dash downward
func start_dashing() -> void:
	current_state = State.DASH
	animated_sprite_2d.play("dash")
	is_dashing = true

# Perform the dash movement
func dash_downward(delta: float) -> void:
	position.y += dash_speed * delta

	# Check if the dash duration has passed, then switch to return state
	if position.y >= original_position.y + dash_speed * dash_duration:
		current_state = State.RETURN
		animated_sprite_2d.play("return")

# Return to the original position after the dash
func return_to_position(delta: float) -> void:
	var distance_to_move = (original_position.y - position.y) / return_duration * delta
	position.y += distance_to_move

	# When back to the original position, reset to IDLE
	if abs(position.y - original_position.y) < 1.0:
		position.y = original_position.y  # Correct any small offsets
		is_dashing = false
		current_state = State.IDLE  # Reset to IDLE after returning
		animated_sprite_2d.play("idle")  # Play idle animation
		
		# Restart the dash timer to control the next dash interval
		dash_timer.start()
