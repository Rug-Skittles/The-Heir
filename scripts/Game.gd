extends Node2D

var gameOverScreen = preload("res://scenes/gameOverScreen.tscn")
var isGameOver : bool = false

var selectedPlayerUnits : Array
var selectedEnemyUnit : Array
var playerUnits : Array[CharacterBody2D]
var enemyUnits : Array[CharacterBody2D]
var allUnits : Array[CharacterBody2D]
var unitToReveal 

var dragSelect = false ## Whether or not dragging is happening
var dragStart = Vector2.ZERO ## Location where drag begins
var selectRectangle = RectangleShape2D.new() ## Collision shape for drag box

var unitsInVision = []

func _ready():
	var tween = create_tween()
	tween.tween_property($musicContainer/AudioStreamPlayer,'volume_db',0,5)
	$musicContainer/AudioStreamPlayer.play()
	
	for unit in allUnits:
		unit.connect('gameOver',handleGameOver)

func handleGameOver():
	if isGameOver == false:
		print('game over')
		add_child(gameOverScreen.instantiate())
		isGameOver = true
		for unit in allUnits:
			_unselectUnit()

func getSelectedUnit():
	var space = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = get_global_mouse_position()
	var intersection = space.intersect_point(query, 1)
	
	if !intersection.is_empty():
		return intersection[0].collider
	return null

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if selectedPlayerUnits.size() != 0:
				for unit in selectedPlayerUnits:
					if unit.currentAction == null:
							_tryCommandUnit()
					## If right clicking after selecting an action, it will unselect that action
					elif unit.currentAction != null:
						print('removing action')
						unit.currentAction = null
						$cursor.visible = false
				
## Searches all vision cones of players to see if the given unit is within.
## Refactor when additional light sources are added to game.
#func isInVision():
	
	
	#for unit in playerUnits:
		#print(playerUnits)
		#for unitInVision in unit.visionCone.get_node('Area2D').get_overlapping_bodies():
			##print(unitInVision)
			#if unitToLookFor == unitInVision:
				#return true
			#else:
				#return false

## Used to remove selection graphics from unit as well as from the selected array
func _unselectUnit():
	$interface.removeStatInterface()
	if selectedPlayerUnits.size() > 0:
		for unit in selectedPlayerUnits:
			unit.selected = false
			unit.toggleSelectionVisual(false)
	selectedPlayerUnits = []
	selectedEnemyUnit = []
	unitToReveal = null

## Sets the target for the player to attack, or to move to a specfic location
func _tryCommandUnit():
	if selectedPlayerUnits == null:
		return
		
	var target = getSelectedUnit()
	
	if target != null and target.isPlayer == false:
		for unit in selectedPlayerUnits:
			unit.setTarget(target)
	else:
		for unit in selectedPlayerUnits:
			unit.moveToLocation(get_global_mouse_position())
			
## Used to add selection graphics to unit and to the selected array
func selectUnit(selection):
	for unit in selection:
		#print(unit)
		for playerUnit in playerUnits:
			for unitToFind in playerUnit.visionCone.get_node('Area2D').get_overlapping_bodies():
				if unit.collider == unitToFind:
					unit.collider.selected = true
					unitToReveal = selection[0].collider
					if unit.collider.isPlayer:
						pass
						unit.collider.toggleSelectionVisual(true)
					else:
						pass
				else:
					pass
## Allows targeting of corpses when needed such as for feasting		
func setTargetToCorpse(unit):
	if getSelectedUnit() != null:
		if getSelectedUnit().isDead and !getSelectedUnit().hiddenCorpse:
			unit.setTarget(getSelectedUnit())
		else:
			$dialogCanvas.queueText('Invalid, target is not a corpse.')
			unit.currentAction = null
			$cursor.visible = false

## Handles rotation of vision cone
func rotateVision(event):
	if selectedPlayerUnits.size() > 0:
		if Input.is_action_just_pressed("mouseWheelUp"):
			for unit in selectedPlayerUnits:
				unit.visionCone.rotation += .075
		elif Input.is_action_just_pressed("mouseWheelDown"):
			for unit in selectedPlayerUnits:
				unit.visionCone.rotation -= .075

func handleSelectionInput(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			## If the mouse was clicked and nothing is selected, start dragging, also removes units
			## from arrays when selecting nothing.
			if selectedPlayerUnits.size() == 0:
				dragSelect = true
				dragStart = event.position
				unitToReveal = null
				selectedPlayerUnits = []
				for unit in selectedEnemyUnit:
					unit.selected = false
				selectedEnemyUnit = []
				
			## Runs if you already have a unit selected and click off of them.
			elif selectedPlayerUnits.size() != 0:
				for unit in selectedEnemyUnit:
					unit.selected = false
				for unit in selectedPlayerUnits:
					if unit.currentAction != 'feast':
						_unselectUnit()
						dragSelect = true
						dragStart = event.position
				
			
		## If the mouse is released and is dragging, stop dragging
		elif dragSelect:
			dragSelect = false
			queue_redraw()
			var dragEnd = event.position
			selectRectangle.extents = abs(dragEnd - dragStart) / 2
			## Finds all the objects inside the rectangle and adds them to selectedUnits
			var space = get_world_2d().direct_space_state
			var query = PhysicsShapeQueryParameters2D.new()
			query.shape = selectRectangle
			query.transform = Transform2D(0, (((dragEnd + dragStart) / 2)+$Camera2D.position)/$Camera2D.zoom)
			for unit in space.intersect_shape(query):
				if !unit.collider.isPlayer and !unit.collider.hiddenCorpse:
					selectedEnemyUnit.append(unit.collider)
				elif unit.collider.isPlayer and !unit.collider.hiddenCorpse:
					selectedPlayerUnits.append(unit.collider)
			selectUnit(space.intersect_shape(query))
			
			
	if event is InputEventMouseMotion and dragSelect:
		queue_redraw()

func handleActiveAction(event):
	for unit in playerUnits:
		if unit.currentAction != null:
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
				if event.pressed:
					if unit.currentAction == 'feast':
						setTargetToCorpse(unit)
					elif unit.currentAction == 'speak':
						unit.trySpeak()
						unit.currentAction = null
						$cursor.visible = false
		else:
			pass
			
func _unhandled_input(event):
	## Rotates the vision cone of a selected unit(s) when mouse wheel is used.
	rotateVision(event)
	## Handles selecting units with left clicking the cursor.
	handleSelectionInput(event)
	## After selection an action from the ability window, this will handle their controls
	handleActiveAction(event)


## Handles all the behavior of buttons on the interface, mainly for actions
func _on_interface_button_down(button):
	if button == 'chase' || button == 'fight' || button == 'passive' || button == 'treat':
		if selectedPlayerUnits.size() != 0:
			for unit in selectedPlayerUnits:
				if unit.aiState == button:
					unit.aiState = 'passive'
					unit.target = null
					unit.agent.target_position = unit.global_position
				else:
					unit.aiState = button

	if button == 'speak' || button == 'feast':
		if selectedPlayerUnits.size() != 0:
			for unit in selectedPlayerUnits:
				unit.currentAction = button
		$cursor.visible = true
		
	if button == 'focus':
		if $Camera2D.keepFocus == true:
			$Camera2D.keepFocus = false
		elif selectedPlayerUnits.size() != 0:
			$Camera2D.keepFocus = true

			

func _process(delta):
	if unitToReveal != null:
		if !unitToReveal.hiddenCorpse:
			$interface.revealStats(unitToReveal)
		
	$cursor.position = get_global_mouse_position()
	
	#isInVision(playerUnits[0])

	#for unit in selectedPlayerUnits:
		#print(unit.currentAction)





func _on_audio_stream_player_finished():
	$musicContainer/AudioStreamPlayer.play()
