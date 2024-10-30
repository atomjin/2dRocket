# Give the component a class name so it can be instanced as a custom node
class_name HurtComponent
extends Node
#@onready var hitbox_component: HitboxComponent = $HitboxComponent
@onready var laser_hitbox: LaserHitbox = $LaserHitbox
@export var stats_component: StatsComponent
@export var hurtbox_component: HurtboxComponent
var current_damage: int = 5 

#func _ready() -> void:
#	hurtbox_component.hurt.connect(func(laser_hitbox: LaserHitbox):
#		stats_component.health -= laser_hitbox.damage
#	)
func _ready() -> void:
	# เชื่อมสัญญาณ hurt เพื่อลด health ตามค่า damage ล่าสุด
	# เชื่อมสัญญาณเมื่อ damage ถูกเพิ่มจาก LaserHitbox
	if laser_hitbox:
		laser_hitbox.damage_increased.connect(_update_damage)
	hurtbox_component.hurt.connect(func(laser_hitbox: LaserHitbox):
		stats_component.health -= laser_hitbox.damage
		
	)

func _update_damage(new_damage: int) -> void:
	print("Health will decrease by: ", new_damage)
