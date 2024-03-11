extends "res://scripts/stateMachine.gd"


func _ready():
	addState('idle')
	addState('moving')
	call_deferred("setState",states.idle)

func _stateLogic(delta):
	#if state == states.moving:
	#	print(get_parent().characterName + ' is moving!')
	pass
	
func _getTransition(delta):
	match state:
		states.idle:
			if get_parent().velocity != Vector2(0,0):
				return states.moving
		states.moving:
			if get_parent().velocity == Vector2(0,0):
				return states.idle
	return null

func _enterState(newState,oldState):
	pass
	
func _exitState(oldState,newState):
	pass 
