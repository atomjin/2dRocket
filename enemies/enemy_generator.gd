extends Node2D

@export var GreenEnemyScene : PackedScene

var margin = 8
var screen_width = ProjectSettings.get_setting("display/window/size/viewport_width")
@onready var spawner_component = $SpawnerComponent as SpawnerComponent
@onready var green_enemy_spawn_timer: Timer = $GreenEnemySpawnTimer
@onready var stats_component: StatsComponent = $StatsComponent

var spawn_connected: bool = true
var is_generating: bool = true
func _ready()->void:
	if is_generating:
		generate_enemy()
		
	
	#if stats_component.health <= 0:
		#
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		if spawn_connected:
			green_enemy_spawn_timer.timeout.disconnect(handle_spawn.bind(GreenEnemyScene, green_enemy_spawn_timer))
			print("Disconnected: SpaceBar pressed")
		else:
			green_enemy_spawn_timer.timeout.connect(handle_spawn.bind(GreenEnemyScene, green_enemy_spawn_timer))
			print("Connected: SpaceBar pressed")
		
		spawn_connected = !spawn_connected
			
func generate_enemy() -> void:
	green_enemy_spawn_timer.timeout.connect(handle_spawn.bind(GreenEnemyScene, green_enemy_spawn_timer))
	print("Enemy generated")  # Placeholder
func handle_spawn(enemy_scene: PackedScene, timer: Timer)->void:
	var num_enemies = randi_range(1, 10)
	for i in range(num_enemies):
		spawner_component.scene = enemy_scene
		spawner_component.spawn(Vector2(randf_range(margin, screen_width-margin),-16))
	timer.start()

func stop_generating() -> void:
	is_generating = false
