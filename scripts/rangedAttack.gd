extends Node2D

var target = null
var speed = 600
var distanceBufferToTarget = 0

@onready var sprite = $sprite



func _ready():
	sprite.texture = get_parent().get_parent().attackSprite
	target = get_parent().get_parent().target
	#print(global_position.distance_to((target.global_position)/speed)+distanceBufferToTarget)
	
	$Timer.start(global_position.distance_to(target.global_position)/speed)
	
func _process(delta):
	if target != null:
		distanceBufferToTarget = sqrt(target.velocity.x*target.velocity.x + target.velocity.y*target.velocity.y)
		
		var direction = (target.global_position - global_position).normalized()
		rotation = direction.angle() + PI/2
		global_position += speed * direction * delta
		
		
		
func _on_timer_timeout():
	var damageDealt = get_parent().get_parent()._damageCalculation(target)
	target._takeDamage(damageDealt)
	get_parent().get_parent().gainExperience(damageDealt, target)
	queue_free()
