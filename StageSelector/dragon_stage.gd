extends TextureRect
@onready var fog_node:TextureRect = $Fog1

# Set the path to the new scene you want to load
@export var new_scene_path: String = "res://world.tscn"

# Reference to the ColorRect used for the transition
@export var transition_node: ColorRect

# Store the duration of the transition effect
@export var transition_duration: float = 1.0

# Track if the transition is already in progress
var is_transitioning: bool = false
var original_size: Vector2
var original_position: Vector2



func _ready() -> void:
	original_size = size
	original_position = position
	# Enable mouse input on the planet node
	mouse_filter = Control.MouseFilter.MOUSE_FILTER_PASS

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		# Check if fog is visible
		if fog_node.visible:
			print("Cannot click on planet, fog is covering it.")
		else:
			print("Planet clicked!")
			get_tree().change_scene_to_file("res://world.tscn")
			

	
func _on_mouse_entered() -> void:
	var new_size = original_size * 1.2
	var new_position = original_position - (new_size - original_size) / 2
	
	size = original_size * 1.2
	position = new_position


func _on_mouse_exited() -> void:
	size = original_size
	position = original_position
