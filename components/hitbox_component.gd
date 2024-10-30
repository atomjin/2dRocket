# Give the component a class name so it can be instanced as a custom node
class_name LaserHitbox
extends Area2D

# Export the damage amount this hitbox deals
@export var damage: int = 5

# Create a signal for when the hitbox hits a hurtbox
signal hit_detect(hurtbox,damage)
signal damage_increased(new_damage)

func _ready():
	area_entered.connect(_on_hurtbox_entered)
	
func _on_hurtbox_entered(hurtbox: HurtboxComponent):
	#if not hurtbox is HurtboxComponent: 
	#	return
	#if hurtbox.is_invincible: 
	#	return
	hit_detect.emit(hurtbox,damage)
	hurtbox.hurt.emit(self)
	
func increase_damage() -> int:
	damage += 10  # Increase damage by 10
	if damage >= 15:  # If damage is 15 or more
		damage = 15  # Set damage to 15
	print("Damage increased to: ", damage)  # For debugging
	return damage  # Return the damageamage
