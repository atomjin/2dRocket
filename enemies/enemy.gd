extends Node2D
@onready var stats_component:  = $StatsComponent as StatsComponent
@onready var move_component:  = $MoveComponent as MoveComponent
@onready var visible_on_screen_notifier_2d:VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var scale_component:  = $ScaleComponent as ScaleComponent
@onready var flash_component:  = $FlashComponent as FlashComponent
@onready var shake_component:  = $ShakeComponent as ShakeComponent
@onready var hurtbox_component:  = $HurtboxComponent as HurtboxComponent
@onready var laser_hitbox: LaserHitbox = $LaserHitbox


@onready var destroyed_component:  = $DestroyedComponent as DestroyedComponent
@onready var score_component:  = $ScoreComponent as ScoreComponent


func _ready():
	stats_component.no_health.connect(func():
		score_component.adjust_score()
		)
	
	visible_on_screen_notifier_2d.screen_exited.connect(queue_free)
	hurtbox_component.hurt.connect(func(hitbox: LaserHitbox):
		scale_component.tween_scale()
		flash_component.flash()
		shake_component.tween_shake()
	)
	stats_component.no_health.connect(queue_free)
	laser_hitbox.hit_detect.connect(destroyed_component.destroy.unbind(1))
 
