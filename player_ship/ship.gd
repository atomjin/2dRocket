extends Node2D
@onready var right_muzzle: Marker2D = $RightMuzzle
@onready var left_muzzle: Marker2D = $LeftMuzzle
@onready var spawner_component: SpawnerComponent = $SpawnerComponent as SpawnerComponent
@onready var fire_rate_timer: Timer = $FireRateTimer
@onready var scale_component: ScaleComponent = $ScaleComponent
@onready var animated_sprite_2d: AnimatedSprite2D = $Anchor/AnimatedSprite2D
@onready var move_component: MoveComponent = $MoveComponent as MoveComponent
@onready var flame_animated_sprite: AnimatedSprite2D= %FlameAnimatedSprite
@onready var stats_component: StatsComponent = $StatsComponent
@onready var animated_timer: Timer = $AnimatedTimer


func _ready():
	fire_rate_timer.timeout.connect(fire_laser)
	stats_component.health_changed.connect(on_health_changed)
	animated_timer.timeout.connect(to_normal_animation)
	pass 

func fire_laser() ->void:
	spawner_component.spawn(left_muzzle.global_position)
	spawner_component.spawn(right_muzzle.global_position)
	scale_component.tween_scale()

func _process(delta: float)->void:
	#animate_the_ship()
	pass	
#func animate_the_ship()->void:
	#if move_component.velocity.x <0:
		#animated_sprite_2d.play("bank_left")
		#flame_animated_sprite.play("bank_left")
	#elif move_component.velocity.x > 0:
	#	animated_sprite_2d.play("bank_right")
	#	flame_animated_sprite.play("bank_right")
	#else :
	#	animated_sprite_2d.play("center")
	
func on_health_changed() -> void:
	animated_sprite_2d.play("hurt") 
	animated_timer.start() 

func to_normal_animation() -> void:
	animated_sprite_2d.play("center")
	
