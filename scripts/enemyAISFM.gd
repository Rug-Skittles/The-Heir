extends "res://scripts/stateMachine.gd"

var unit = null


func _ready():
	unit = get_parent()
	
	addState('PASSIVE')
	addState('GUARD')
	addState('CHASE')
	addState('PATROL')
	addState('HIDE')
	addState('FLEE')
	#await get_tree().create_timer(.5).timeout
	call_deferred("setState",states[unit.startingState])

func _stateLogic(delta):
	if !unit.aiDisabled:

		if state == states.PASSIVE:
			pass
		elif state == states.GUARD:
			if getTargetInRange() != null:
				if getTargetInRange().global_position.distance_to(unit.homePosition) <= unit.guardDistance and !getTargetInRange().isDead:
					if unit.global_position.distance_to(getTargetInRange().global_position) <= unit.guardDistance:
						unit.setTarget(getTargetInRange())
				else:
					unit.target = null
					unit.agent.target_position = unit.homePosition
		elif state == states.CHASE:
			unit.setTarget(getTargetInRange())
		elif state == states.PATROL:
			pass
		elif state == states.HIDE:
			pass
		elif state == states.FLEE:
			pass
		pass
		
func checkStateList(stateString):
	for item in unit.stateList:
		if item == stateString:
			return true
		else:
			return false
		
func _getTransition(delta):
	match state:
		#states.PASSIVE:
			#if get_parent().target != null:
				#return states.CHASE
		states.CHASE:
			if unit.baseStats['curWounds'] < unit.baseStats['maxWounds']:
				if checkStateList('FLEE'):
					print('SWITCHING TO FLEE')
					return states.FLEE
			elif getTargetInRange() == null:
				if checkStateList('PATROL'):
					print('SWITCHING TO PATROL')
					return states.PATROL
		states.PATROL:
			if getTargetInRange() != null:
				if checkStateList('CHASE'):
					print('SWITCHING TO CHASE')
					return states.CHASE
	return null

func _enterState(newState,oldState):
	match newState:
		states.PASSIVE:
			pass
		states.GUARD:
			unit.homePosition = unit.global_position
		states.CHASE:
			pass
		states.PATROL:
			unit.homePosition = unit.global_position
			newPatrolPosition()
		states.HIDE:
			pass
		states.FLEE:
			flee()
	
func _exitState(oldState,newState):
	pass 
	
func randomOffset():
	var offset = Vector2(randf_range(-1, 1),randf_range(-1, 1))
	return offset.normalized()
	
func newPatrolPosition():
	var pos = unit.homePosition + randomOffset() * randf_range(0, unit.maxPatrolRange)

	unit.navigationComplete = false
	unit.agent.target_position = pos

func getTargetInRange():
	var target = null
	var lowestDistance = float(INF)
	
	for nearestTarget in unit.gameManager.playerUnits:
		if !nearestTarget.isDead:
			var distance = unit.global_position.distance_to(nearestTarget.global_position)
			if distance-50 < lowestDistance:
				if distance <= unit.sightRange:
					lowestDistance = distance
					target = nearestTarget
	return target
				
func flee():
	print(unit)
	print(unit.target)
	var playerDirection = (unit.position - unit.target.position).normalized()
	unit.target = null
	unit.agent.target_position = unit.position + (playerDirection * unit.fleeDistance)
	
	
func _on_enemy_unit_movement_complete(unitRecieved):
	print('RECIEVED')
	if unitRecieved == unit and state == states.PATROL:
		print(unitRecieved)
		var waitTime = randf_range(unit.minWaitTime,unit.maxWaitTime)
		await get_tree().create_timer(waitTime).timeout
		
		newPatrolPosition()

#func _process(delta):
	#processChase()
