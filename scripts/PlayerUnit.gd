extends Unit

@onready var selectionVisual : Sprite2D = get_node("selectionVisual")
@onready var visionCone = $visionCone

var aiState = 'passive'
var treatmentTarget = null

var hungerMsg = 2




func handleAiState():
	#print(aiState)
	if aiState == 'chase' and target == null and velocity == Vector2(0,0):
		var bodiesInView = []
		var enemiesInView = []
		for body in visionCone.get_node('Area2D').get_overlapping_bodies():
			if !body.isPlayer and !body.isDead:
				enemiesInView.append(body)
		if enemiesInView.size() > 0:
			target = enemiesInView[0]
	
	if aiState == 'fight':
		if lastAttacker != null and !lastAttacker.isDead and !lastAttacker.isPlayer:
			if velocity == Vector2(0,0):
				target = lastAttacker
		else:
			if aiState == 'fight':
				var bodiesInView = []
				var enemiesInView = []
				for body in visionCone.get_node('Area2D').get_overlapping_bodies():
					if !body.isNeutral and !body.isPlayer and !body.isDead and body != self:
						enemiesInView.append(body)
				if enemiesInView.size() > 0:
					for enemy in enemiesInView:
						if global_position.distance_to(enemy.global_position) <= modifiedStats['attackRange']:
							target = enemy
				
	
	if aiState == 'treat':
		if isPhysician:
			isTreating = true
			for unit in get_parent().get_parent().playerUnits:
				if unit != self and treatmentTarget == null:
					if unit.isBleeding || unit.timeSinceLastTreatment <= Time.get_unix_time_from_system() - 60 and unit.baseStats['curWounds'] < unit.baseStats['maxWounds']:
						if global_position.distance_to(unit.global_position) <= modifiedStats['attackRange']:
							#print('TREATING!')
							agent.target_position = unit.global_position
							unit.agent.target_position = unit.global_position
							treatmentTarget = unit
							if $treatmentTimer.is_stopped():
								$treatmentTimer.timeout.connect(_on_treatmentTimer_timeout)
								$treatmentTimer.start(4.0)

				elif treatmentTarget != null:
					agent.target_position = treatmentTarget.global_position
					treatmentTarget.agent.target_position = treatmentTarget.global_position		
		else:
			aiState = 'passive'
	else:
		isTreating = false
					
	
	pass

func toggleSelectionVisual(toggle):
	selectionVisual.visible = toggle

func handleSpriteFacing():
	## Experimental code to snap vision cone towards the target
	#var directionToPoint = Vector2(global_position.direction_to(agent.get_next_path_position()).y, global_position.direction_to(agent.get_next_path_position()).x)
	#visionCone.rotation = directionToPoint.angle() * -1
	#$Sprite2D.rotation = directionToPoint.angle()
	if visionCone.global_rotation_degrees > 0:
		sprite.flip_h = false
	elif visionCone.global_rotation_degrees <0:
		sprite.flip_h = true
	
## Every x time from hungerTick reduces the unit's hunger by an amount modified by their survival.
## Additionally more hunger will be reduced if the unit is moving.
func _on_timer_timeout():
	if isPlayer:

		var survivalModifier = modifiedStats['survival'] * 0.1
		if velocity != Vector2(0,0):
			hunger -= 1.05 - survivalModifier
		else:
			hunger -= 0.8 - survivalModifier
		if hunger <= 0:
			hunger = 0
			if !baseStats['curWounds'] <= 0:
				baseStats['curWounds'] -= round(baseStats['maxWounds'] * .05)
				hungerMsg += 1
			if baseStats['curWounds'] <= 0:
				generateCorpse()
			if hungerMsg == 3:
				dialogCanvas.processText([characterName + ' is starving!'])
				hungerMsg = 1
			
			
## Work on healing functionality later
func _on_treatmentTimer_timeout():
	treatmentTarget.timeSinceLastTreatment = Time.get_unix_time_from_system()
	treatmentTarget.isBleeding = false
	treatmentTarget.baseStats['curWounds'] += modifiedStats['survival']
	$treatmentTimer.stop()
	treatmentTarget = null
	print('Treatment Complete!')
	
	

func _process(delta):
	print(fatigue)
	targetCheck()
	handleSpriteFacing()
	checkDeath()
	_checkStatus()
	handleLevelUp()
	handleAiState()
	if isFrenzied:
		aiState = 'chase'
