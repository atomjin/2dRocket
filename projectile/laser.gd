extends Node2D

@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var scale_component:ScaleComponent = $ScaleComponent as ScaleComponent
@onready var flash_component: FlashComponent = $FlashComponent as FlashComponent
#@onready var hitbox_component: HitboxComponent = $HitboxComponent

@onready var laser_hitbox: LaserHitbox = $LaserHitbox


func _ready()->void:
	scale_component.tween_scale()
	flash_component.flash()
	#fucn to kill the spawn laser
	visible_on_screen_notifier_2d.screen_exited.connect(queue_free)
	laser_hitbox.hit_detect.connect(queue_free.unbind(1))
