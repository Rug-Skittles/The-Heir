extends "res://scripts/stateMachine.gd"

func _ready():
	addState('noAction')
	addState('talk')
	addState('feast')
	call_deferred("setState",states.noAction)

func _stateLogic(delta):

	#if state == states.passive:
		##print(get_parent().characterName + ' is not attacking')
		#pass
	#elif state == states.attacking:
		##print(get_parent().characterName + ' is making an attack')
		#pass
	pass
	
func _getTransition(delta):
	#match state:
		#states.noAction:
			#if get_parent().currentAction != null:
				#print(get_parent().currentAction)
				#return states.currentAction
		#states.attacking:
			#if get_parent().target == null:
				#return states.passive
	return null

func _enterState(newState,oldState):
	pass
	
func _exitState(oldState,newState):
	pass 
