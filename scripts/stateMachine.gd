extends Node
class_name StateMachine

var state = null
var previousState = null
var states = {}

@onready var parent = get_parent()

func _physics_process(delta):
	if state != null:
		_stateLogic(delta)
		var transition = _getTransition(delta)
		if transition != null:
			setState(transition)


func _stateLogic(delta):
	pass
	
func _getTransition(delta):
	return null

func _enterState(newState,oldState):
	pass
	
func _exitState(oldState,newState):
	pass

func setState(newState)	:
	previousState = state
	state = newState
	
	if previousState != null:
		_exitState(previousState,newState)
	if newState != null:
		_enterState(newState,previousState)
		
func addState(stateName):
	states[stateName] = states.size()
