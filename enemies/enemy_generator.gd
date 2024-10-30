extends Node2D

@export var GreenEnemyScene : PackedScene

var margin = 8
var screen_width = ProjectSettings.get_setting("display/window/size/viewport_width")

@onready var spawner_component = $SpawnerComponent as SpawnerComponent
@onready var green_enemy_spawn_timer: Timer = $GreenEnemySpawnTimer

func _ready()->void:
	green_enemy_spawn_timer.timeout.connect(handle_spawn.bind(GreenEnemyScene, green_enemy_spawn_timer))
	 

func handle_spawn(enemy_scene: PackedScene, timer: Timer)->void:
	var num_enemies = randi_range(1, 3)
	for i in range(num_enemies):
		spawner_component.scene = enemy_scene
		spawner_component.spawn(Vector2(randf_range(margin, screen_width-margin),-16))
	timer.start()
