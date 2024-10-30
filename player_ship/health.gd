extends Control  # Updated from Node2D to Control

# Array to store the health TextureRects
var health_units: Array[TextureRect] = []

# Reference to the StatsComponent node
@export var stats_component: StatsComponent  
#@onready var stats_component: StatsComponent = $StatsComponent


func _ready():
	health_units = [
		$BlankHeart/health1,
		$BlankHeart/health2,
		$BlankHeart/health3
	]
	
# Connect the health signals from StatsComponent
	stats_component.connect("health_changed", Callable(self, "_on_health_changed"))
	stats_component.connect("no_health", Callable(self, "_on_no_health"))
# Ensure the health units are visible initially
	#_update_health_display(0)
	#_update_health_display(stats_component.health)
	_on_stats_component_health_changed(stats_component.health)
#func _on_health_changed(current_health: int):
#	print("Current health: ", current_health)  # Debug
#	_update_health_display(current_health)
	
#func _on_no_health():
#	# Optionally, handle what happens when health reaches 0
#	print("No health left! Game Over.")
	
func _update_health_display(current_health: int):
# Ensure the correct TextureRects are visible/invisible based on health
	for i in range(len(health_units)):
		if i < current_health:
			health_units[i].visible = true  # Keep visible
		else:
			health_units[i].visible = false  # Hide if health is lost


func _on_stats_component_health_changed(current_health) :
	#if current_health < current_health:
		print("Current health: ", current_health)  # Debug
		_update_health_display(current_health)


func _on_stats_component_no_health():
	print("No health left! Game Over.")
