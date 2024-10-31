class_name BossSnake
extends "res://enemies/enemy.gd"

@onready var state: Node = $State
@onready var move_state: TimedStateComponent = $State/MoveState as TimedStateComponent
@onready var move_side_state: TimedStateComponent = $State/MoveSideState as TimedStateComponent
@onready var pause_state: TimedStateComponent = $State/PauseState as TimedStateComponent
@onready var move_side_component: MoveComponent = $State/MoveSideState/MoveSideComponent as MoveComponent
@onready var attack_state: StateComponent = $State/AttackState as StateComponent
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var laser_spawner: SpawnerComponent = %LaserSpawner

signal no_health

var laser_offset: Vector2 = Vector2(0, 525)
@export var laser_duration: float = 5.0
@export var attack_delay: float = 1.0
var health: int = 75
var spawned_instances: Array[Node] = []
signal boss_defeated

func _ready() -> void:
	super()

	# Connect the no_health signal to call the destroy function
	stats_component.no_health.connect(on_boss_defeated)
	
	# Disable all states initially
	for child in state.get_children():
		var child_state = child as StateComponent
		child_state.disable()

	# Set the initial random velocity for side movement
	move_side_component.velocity.x = [-500, 500].pick_random()

	# State transitions
	move_state.state_finished.connect(move_side_state.enable)
	move_side_state.state_finished.connect(prepare_for_attack)
	attack_state.state_finished.connect(pause_state.enable)
	pause_state.state_finished.connect(move_state.enable)

	# Start with the initial movement state
	move_state.enable()

func on_boss_defeated() -> void:
	emit_signal("boss_defeated")  # Notify main scene
	queue_free()  # Destroy BossSnake instance
func apply_damage(damage: int) -> void:
	health -= damage
	print("BossSnake health:", health)  # Debugging output
	if health <= 0:
		emit_signal("no_health")

func destroy() -> void:
	for instance in spawned_instances:
		if instance and instance.is_inside_tree():
			instance.queue_free()
	queue_free() # Remove BossSnake from the scene

# Prepare for the laser attack: stop movement and start the attack animation
func prepare_for_attack() -> void:
	move_side_component.velocity.x = 0
	animated_sprite_2d.play("attack")
	await get_tree().create_timer(attack_delay).timeout
	fire_laser()

# Fires the laser and sets it to disappear after `laser_duration`
func fire_laser() -> void:
	attack_state.enable()
	scale_component.tween_scale()

	# Spawn laser at an offset below the boss's position
	var laser_instance = laser_spawner.spawn(global_position + laser_offset)

	# Start a timer to remove the laser and resume movement
	start_laser_removal_timer(laser_instance)

	# Disable attack state after spawning laser
	attack_state.disable()
	attack_state.state_finished.emit()

# Removes the laser after the specified duration
func start_laser_removal_timer(laser_instance):
	await get_tree().create_timer(laser_duration).timeout
	animated_sprite_2d.play("default")  # Change back to the default animation after attack

	# Remove the laser instance
	if laser_instance:
		laser_instance.queue_free()

	# Resume random movement on the x-axis
	move_side_component.velocity.x = [-500, 500].pick_random()
