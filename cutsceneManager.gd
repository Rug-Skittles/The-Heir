extends Node2D

var dialogCanvas = null

var actionsQueue = []
var processing : bool = false

var currentSpeed = null
var newSpeed = null
var lastMovedUnit = null


signal startAction
signal sendUnit(unit)


func _ready():
	dialogCanvas = get_parent().get_node('dialogCanvas')
	for unit in get_tree().get_nodes_in_group("units"):
		unit.connect('movementComplete',onUnitMovementComplete)

func addAction(actionType, data):
	var action = CutsceneAction.new()
	action.type = actionType
	action.data = data
	actionsQueue.append(action)
	
	# addAction('movement', {'character': 'CharacterName',
#							{'destination': 'Vector2(x,y)'}							
	# addAction('dialog', {'text':['Text 1', 'Text 2', 'Text 3'], 
#							'script':['Speaker 1, Speaker 2, Speaker 3]})
	
func processNextAction():
	if actionsQueue.size() > 0:
		processing = true
		var action = actionsQueue.pop_front()
		match action.type:
			'dialog':
				processDialog(action)
			'movement':
				processMovement(action)
			'attack':
				processAttack(action)
			'setTarget':
				processTarget(action)

				
func processDialog(action):
	dialogCanvas.processText(action.data['text'], 'pauseFocus', action.data['script'], 'high')

func processMovement(action):
	get_parent().get_node("currentWorld").get_node("unitContainer").process_mode = Node.PROCESS_MODE_INHERIT
	startAction.emit()
	for enemy in get_parent().enemyUnits:
		enemy.aiDisabled = true
	var unit = action.data['character']
	
	for character in get_parent().allUnits:
		if unit == character.characterName:
			lastMovedUnit = character
			if action.data.has('flip'):
				if action.data['flip'] == 'true':
					character.sprite.flip_h = true
				elif action.data['flip'] == 'false':
					character.sprite.flip_h = false
			if action.data.has('speed'):
				currentSpeed = character.baseStats['movement']
				newSpeed = action.data['speed']
				character.baseStats['movement'] = newSpeed
			if action.data.has('rotation') and !action.data.has('rotationLength'):
				print('NO ROTATION LENGTH')
				var tween = create_tween()
				tween.tween_property(character.get_node('Sprite2D'),'rotation_degrees',action.data['rotation'],1)
			elif action.data.has('rotation') and action.data.has('rotationLength'):
				print('HAS ROTATION LENGTH')
				var tween = create_tween()
				tween.tween_property(character.get_node('Sprite2D'),'rotation_degrees',action.data['rotation'],action.data.has('rotationLength'))
			if action.data.has('destination'):
				var destination = action.data['destination']
				if action.data['destination'] is String:
					for targetUnit in get_parent().allUnits:
						if targetUnit.characterName == action:
							character.agent.target_position = targetUnit.global_position
				elif action.data['destination'] is Vector2:
					var globalDestination = to_global(destination)
					character.agent.target_position = globalDestination
				
				
			character.navigationComplete = false
			sendUnit.emit(character)
			
func processAttack(action):
	startAction.emit()
	var unitName = action.data['character']
	var targetName = action.data['target']
	var targetToAttack = null
	for unit in get_parent().allUnits:
		if targetName == unit.characterName:
			targetToAttack = unit
	for character in get_parent().allUnits:
		if unitName == character.characterName:
			sendUnit.emit(character)
			character.target = targetToAttack
			character._tryAttackTarget()
			character.target = null
			
func processTarget(action):
	var unitName = action.data['character']
	var targetName = action.data['target']
	var targetToAttack = null
	for unit in get_parent().allUnits:
		if targetName == unit.characterName:
			targetToAttack = unit
	for character in get_parent().allUnits:
		if unitName == character.characterName:
			character.target = targetToAttack
	processing = false
			
			

	
#func processLight(action):
	#var unitName = action.data['character']
	#if action.data['light'] == 'radial':
		#for unit in get_parent().allUnits:
			#if unit.characterName == unitName:
				#unit.get_node('radialVision').show()
		

func onUnitMovementComplete(unit):
	if unit == lastMovedUnit:
		print('COMPLETE MOVE NOW')
		for enemy in get_parent().enemyUnits:
			if !enemy.isNeutral:
				enemy.aiDisabled = false
		unit.baseStats['movement'] = currentSpeed
		currentSpeed = null
		newSpeed = null	
		lastMovedUnit = null



func _process(delta):

	#print(actionsQueue)
	if processing and lastMovedUnit != null:
		get_parent().get_node('Camera2D').focusCamera(lastMovedUnit,1.5)
		
		
	if !processing:
		processNextAction()
