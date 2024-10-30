extends "res://enemies/enemy.gd"

@onready var timer: Timer = %Timer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@export var player:Node2D
@export var move_speed: float = 100

var moving_to_player: bool = false

func _ready() -> void:
	
	# Call the parent class's _ready method
	super()
	move_component.velocity.y = 50
	# Set up the delay timer
	if timer:
		timer.timeout.connect(start_moving_to_player)  # Connect timeout to start function
		timer.start()  # Start the delay timer
	else:
		push_error("Timer node 'DelayTimer' not found.")

func _process(delta: float) -> void:
	if moving_to_player:
		move_toward_player(delta)

# Function to handle movement toward the player
func move_toward_player(delta: float) -> void:
	if player:
		var direction = (player.global_position - global_position).normalized()
		
		position += direction * move_speed * delta
	

# Function called after delay to start moving and change animation
func start_moving_to_player() -> void:
	moving_to_player = true
	animated_sprite_2d.play("aggo")  # Start the "aggo" animation (replace with your actual animation name)
	
	
func set_player(player_node: Node2D)-> void:
	player = player_node
