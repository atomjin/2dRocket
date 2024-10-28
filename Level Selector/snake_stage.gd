extends TextureRect
@onready var new_scene_path: String = "res://world.tscn"

# Drag the fog node from the scene tree to this variable in the editor
@onready var fog_node: TextureRect = $Fog1
var original_size: Vector2
var original_position: Vector2


func _ready() -> void:
	original_size = size
	original_position = position
	# Enable mouse input on the planet node
	mouse_filter = Control.MouseFilter.MOUSE_FILTER_PASS
	connect("gui_input", Callable(self, "_on_gui_input"))
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		# Check if fog is visible
		if fog_node.visible:
			print("Cannot click on planet, fog is covering it.")
		else:
			print("Planet clicked!")
			change_scene()
			# Handle the click action for the planet here

func change_scene():
	var root = get_tree().root
	for child in root.get_children():
		child.queue_free()
	
	var new_scene=load(new_scene_path).instantiate()
	root.add_child(new_scene)


func _on_mouse_entered() -> void:
	var new_size = original_size * 1.2
	var new_position = original_position - (new_size - original_size) / 2

	size = new_size
	position = new_position


func _on_mouse_exited() -> void:
	size = original_size
	position = original_position
