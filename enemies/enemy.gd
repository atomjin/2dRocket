extends Node2D
@onready var stats_component:  = $StatsComponent as StatsComponent
@onready var move_component:  = $MoveComponent as MoveComponent
@onready var visible_on_screen_notifier_2d:VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var scale_component:  = $ScaleComponent as ScaleComponent
@onready var flash_component:  = $FlashComponent as FlashComponent
@onready var shake_component:  = $ShakeComponent as ShakeComponent
@onready var hurtbox_component:  = $HurtboxComponent as HurtboxComponent
@onready var hitbox_component: = $HitboxComponent as HitboxComponent
@onready var destroyed_component:  = $DestroyedComponent as DestroyedComponent
@onready var score_component:  = $ScoreComponent as ScoreComponent

@export var player: Node2D
@export var move_speed: float = 100.0 

func _ready() -> void:
	# Connect signals
	stats_component.no_health.connect(on_no_health)
	visible_on_screen_notifier_2d.screen_exited.connect(queue_free)
	hurtbox_component.hurt.connect(on_hurt)
	hitbox_component.hit_hurtbox.connect(destroyed_component.destroy.unbind(1))

func _process(delta: float) -> void:
	move_toward_player(delta)

# Function to handle enemy moving toward player
func move_toward_player(delta: float) -> void:
	if player:
		var direction = (player.global_position - global_position).normalized()
		position += direction * move_speed * delta

# Function called when health reaches zero
func on_no_health() -> void:
	score_component.adjust_score()
	queue_free()

# Function called when enemy is hurt
func on_hurt(hitbox: HitboxComponent) -> void:
	scale_component.tween_scale()
	flash_component.flash()
	shake_component.tween_shake()
	

 
