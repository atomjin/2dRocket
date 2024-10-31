extends Node2D

@export var GreenEnemyScene: PackedScene
@export var TigerEnemyScene: PackedScene
@export var SheepEnemyScene: PackedScene
@export var player: Node2D

var margin = 8
var screen_width = ProjectSettings.get_setting("display/window/size/viewport_width")
@onready var spawner_component = $SpawnerComponent as SpawnerComponent  # Single spawner component
@onready var green_enemy_spawn_timer: Timer = $GreenEnemySpawnTimer
@onready var tiger_enemy_spawn_timer: Timer = $TigerEnemySpawnTimer
@onready var sheep_enemy_spawn_timer: Timer = $SheepEnemySpawnTimer
@onready var stats_component: StatsComponent = $StatsComponent

var spawn_connected: bool = true
var is_generating: bool = true

func _ready() -> void:
	if is_generating:
		generate_enemy()
		
	green_enemy_spawn_timer.start()
	tiger_enemy_spawn_timer.start()
	sheep_enemy_spawn_timer.start()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		if spawn_connected:
			disconnect_spawns()
			print("Disconnected: SpaceBar pressed")
		else:
			connect_spawns()
			print("Connected: SpaceBar pressed")
		
		spawn_connected = !spawn_connected

func generate_enemy() -> void:
	connect_spawns()
	print("Enemy generated")  # Placeholder

func connect_spawns():
	green_enemy_spawn_timer.timeout.connect(spawn_green_enemies)
	tiger_enemy_spawn_timer.timeout.connect(spawn_tiger_enemy)
	sheep_enemy_spawn_timer.timeout.connect(spawn_sheep_enemies)

func disconnect_spawns():
	green_enemy_spawn_timer.timeout.disconnect(spawn_green_enemies)
	tiger_enemy_spawn_timer.timeout.disconnect(spawn_tiger_enemy)
	sheep_enemy_spawn_timer.timeout.disconnect(spawn_sheep_enemies)
	
func spawn_green_enemies() -> void:
	var num_enemies = randi_range(1, 10)
	spawner_component.scene = GreenEnemyScene  # Set scene to green enemy
	#print("Spawning", num_enemies, "green enemies")  # Debug print
	for i in range(num_enemies):
		spawner_component.spawn(Vector2(randf_range(margin, screen_width - margin), -16))
	green_enemy_spawn_timer.start()

func spawn_tiger_enemy() -> void:
	spawner_component.scene = TigerEnemyScene  # Set scene to tiger enemy
	#print("Spawning 1 tiger enemy")  # Debug print
	spawner_component.spawn(Vector2(randf_range(margin, screen_width - margin), 220))
	tiger_enemy_spawn_timer.start()

func spawn_sheep_enemies() -> void:
	var num_enemies = randi_range(1, 2)
	spawner_component.scene = SheepEnemyScene  # Set scene to sheep enemy
	#print("Spawning", num_enemies, "sheep enemies")  # Debug print
	for i in range(num_enemies):
		var sheep_instance = spawner_component.spawn(Vector2(randf_range(margin, screen_width - margin), -16))
		if sheep_instance.has_method("set_player"):
			sheep_instance.set_player(player)
	sheep_enemy_spawn_timer.start()


func stop_generating() -> void:
	is_generating = false
