class_name StatsComponent
extends Node
@onready var enemy_generator: Node2D = $EnemyGenerator



# Create the health variable with a setter
@export var health: float = 4.00:
	set(value):
		health = value
		# Emit the health_changed signal with the new health value
		health_changed.emit(health)  
		if health == 0:
			no_health.emit()
			#enemy_generator.stop_generating()
func _ready():
	health -= 0  # Simulate taking 1 hit
	
	
	
# Create signals for health changes
signal health_changed(current_health) # Pass the current health as a parameter
signal no_health() # Emit when health reaches 0
