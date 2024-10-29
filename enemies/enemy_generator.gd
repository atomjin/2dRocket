extends Node2D

@export var GreenEnemyScene : PackedScene
@export var BossScene : PackedScene
@export var SheepEnemy : PackedScene
@export var player: Node2D

@onready var spawner_component = $SpawnerComponent as SpawnerComponent
@onready var green_enemy_spawn_timer: Timer = $GreenEnemySpawnTimer
@onready var sheep_enemy_timer: Timer = $SheepEnemyTimer

var margin = 8
var screen_width = ProjectSettings.get_setting("display/window/size/viewport_width")
var enemy_count: int =0
const spawn_boss_condision: int = 30

func _ready()->void:
	green_enemy_spawn_timer.timeout.connect(handle_spawn.bind(GreenEnemyScene, green_enemy_spawn_timer))
	sheep_enemy_timer.timeout.connect(handle_spawn.bind(SheepEnemy,sheep_enemy_timer))

func handle_spawn(enemy_scene: PackedScene, timer: Timer)->void:
	var num_enemies = randi_range(1, 3)
	for i in range(num_enemies):
		if enemy_count > spawn_boss_condision:
			spawn_boss()
			enemy_count = 0
		else:
			var enemy_instance = enemy_scene.instantiate()
			spawner_component.scene = enemy_scene
			enemy_instance.position = Vector2(randf_range(margin, screen_width-margin),-16)
			if enemy_scene == SheepEnemy:
				enemy_instance.set_player(player) 
				
			get_parent().add_child(enemy_instance)
				
			enemy_count += 1
			
	timer.start()
	
func spawn_boss()-> void:
	spawner_component.scene = BossScene
	spawner_component.spawn(Vector2(screen_width / 2,225))
	
