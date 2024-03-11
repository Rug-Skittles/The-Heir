extends "res://scripts/stateMachine.gd"


func _ready():
	addState('ready')
	addState('typing')
	addState('finished')
	call_deferred("setState",states.ready)

func _stateLogic(delta):
	#if state == states.moving:
	#	print(get_parent().characterName + ' is moving!')
	pass
	
func _getTransition(delta):
	match state:
		states.ready:
			pass
		states.typing:
			pass
	return null

func _enterState(newState,oldState):
	pass
	
func _exitState(oldState,newState):
	pass 
