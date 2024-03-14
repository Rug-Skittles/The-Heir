extends CharacterBody2D
class_name Unit

@export var characterName = 'placeholder'
@export var level : int
@export var sprite : Sprite2D
@export var attackSprite : Texture
@export var fatigue : int = 0
@export var hunger : float = 100
@export var canDie : bool = true
var bleedMsg = 3

@export var voicePitch : float = 1.0

@export var baseStats : Dictionary = {
									'maxWounds':10,
									'curWounds':10,
									'might':5,
									'skill':5,
									'agility':5,
									'resilience':5,
									'survival':5,
									'movement':150,
									'attackRange':150,
									'attackRate':0.5,
									'fatigue':0,
									'hunger':100
										}
										
@export var growthRates : Dictionary = {
									'maxWounds':0,
									'might':0,
									'skill':0,
									'agility':0,
									'resilience':0,
									'survival':0,
									'movement':0,
										}

var modifiedStats : Dictionary = {
									'might':null,
									'skill':5,
									'agility':5,
									'resilience':5,
									'survival':5,
									'movement':150,
									'attackRange':150,
									'attackRate':0.5
									}

var combatExperience : float 

@export var isDead : bool = false
@export var isPlayer : bool = false
var isNeutral : bool = false
@export var isFatigued : bool = false
@export var isDiseased : bool = false
@export var isFrenzied : bool = false
@export var isBleeding : bool = false
@export var isPhysician : bool = false
@export var isRecruitable : bool = false

@export var actions : Array[Dictionary] = [ 
	{'Speak' : true},
	{'Feast' : true} ]

@export var attackDialog : Array[String]
@export var idleDialog : Array[String]
@export var feastDialog : Array[String]
@export var deathDialog : Array[String]


@export var keepFocus : bool = false

@export var emitDeathSignal : bool = false
var deathSignalEmitted : bool = false

var lastAttacker = null

var currentAction = null
var isTreating : bool = false
var timeSinceLastTreatment = 0

var allowedToMove : bool = true
var allowedToTarget : bool = true

var selected = false

var lastAttackTime : float
var target : CharacterBody2D
var agent : NavigationAgent2D
var navigationComplete : bool = true

var dialogCanvas

var corpsesEaten : int = 0

var game 


var deathChecked : bool 
var hiddenCorpse : bool = false

signal movementComplete(unit)
signal attackComplete(unit)
signal gameOver

signal deathSignal(unit)

## Handles status effects changes to stat values
func getModifier(stat):
	if stat == 'might':
		var modifier = 0
		if isFatigued:
			modifier += -1
		if isDiseased:
			modifier += -2
		if isFrenzied:
			modifier += 2
		if isTreating:
			modifier -= baseStats[stat]/2
		return modifier
	if stat == 'skill':
		var modifier = 0
		if isFatigued:
			modifier += -2
		if isDiseased:
			modifier += -1
		if isBleeding:
			modifier += -1
		if isTreating:
			modifier -= baseStats[stat]/2
		return modifier
	if stat == 'agility':
		var modifier = 0
		if isFatigued:
			modifier += -3
		if isDiseased:
			modifier += -1
		if isBleeding:
			modifier += -1
		if isTreating:
			modifier -= baseStats[stat]/2
		return modifier
	if stat =='resilience':
		var modifier = 0
		if isDiseased:
			modifier += -2
		if isTreating:
			modifier -= baseStats[stat]/2
		return modifier
	if stat == 'survival':
		var modifier = 0
		if isDiseased:
			modifier += -2
		return modifier
	if stat == 'movement':
		var modifier = 0
		if isFatigued:
			modifier += -25
		if isTreating:
			modifier -= baseStats[stat]/2
		return modifier
	else:
		return 0
		
	

func _checkStatus():
	if !isDead:
		for stat in modifiedStats:
			modifiedStats[stat] = baseStats[stat] + getModifier(stat)
		if isBleeding:
			if $bleedTimer.is_stopped():
				$bleedTimer.start(6+modifiedStats['survival']/2)
		else:
			if !$bleedTimer.is_stopped():
				$bleedTimer.stop()
	if fatigue >= 100:
		isFatigued = true
	else: 
		isFatigued = false


func initStats():
	for stat in modifiedStats:
		modifiedStats[stat] = baseStats[stat]


func _ready():
	dialogCanvas = get_node("/root/Game/dialogCanvas")
	add_to_group("units")
	agent = $NavigationAgent2D
	sprite = $Sprite2D
	
	game = get_node("/root/Game")

	
	game.allUnits.append(self)
	
	if isPlayer:
		game.playerUnits.append(self)
	else:
		game.enemyUnits.append(self)
		
	## Initialize stats
	initStats()
	
	## Sets the 'idleTimer' length to a random range in seconds
	## This will control when a unit's idle dialog is fired.
	$idleTimer.wait_time = randi_range(240,480)
	$idleTimer.start()
	
	## Returns a random number between 1 and 5 + the unit's might
	## May want to tweak the roll for balance later on

func randRoll(target):
	var modifier = (modifiedStats['might'] - round((target.modifiedStats['agility']*1.25)))
	if modifier <= 0:
		modifier = 0
	var roll = randi() % (6 + int(modifier)) + 2
	print(roll)
	return roll
	
func _damageCalculation(target):
	if !target.isDead:
		var damageDealt = (modifiedStats['skill'] - int(round((target.modifiedStats['resilience']*1.25)))) + randRoll(target)
		if damageDealt >= 0:
			return damageDealt
		elif damageDealt <= 0:
			return 1
	else:
		return 0
	
func _takeDamage(damageToTake):
	baseStats['curWounds'] -= damageToTake
	if baseStats['curWounds'] <= 0:
		generateCorpse()
	sprite.modulate = Color.DARK_RED
	await get_tree().create_timer(0.15).timeout
	sprite.modulate = Color.WHITE
	var bleedRoll = randi() % 100 + 1
	if bleedRoll <= 1 + round(damageToTake*0.4):
		isBleeding = true
		
	$audioContainer/takeDamage.play()

func _tryAttackTarget():
	var currentTime = Time.get_unix_time_from_system()
	if currentTime - lastAttackTime > (modifiedStats['attackRate']-(modifiedStats['agility']*0.0125)) and !target.isDead and allowedToTarget:
		actionDialog('attack')
		var projectile = load("res://scenes/rangedAttack.tscn")
		var projectileInstance = projectile.instantiate()
		$projectileContainer.add_child(projectileInstance)
		lastAttackTime = currentTime
		if fatigue <= 198:
			fatigue += 2.35
		if target != null:
			target.lastAttacker = self
		await get_tree().create_timer(global_position.distance_to(target.global_position)/600).timeout
		attackComplete.emit(self)
		
func gainExperience(damageDealt, target):
	combatExperience += damageDealt

func handleLevelUp():
	if combatExperience >= 70 + (level * 5):
		var levelUpString = ''
		for stat in growthRates:
			if checkGrowths(stat):
				print('Raised ' + stat)
				baseStats[stat] += 1
				levelUpString += stat + ' - '
		if levelUpString != '':
			dialogCanvas.processText([characterName + ' improved ' + levelUpString])
		print('Level Up!')
		combatExperience = 0
		level += 1
	else:
		pass
	
func handleCannialismGains(corpse):
	var eater = game.selectedPlayerUnits[0]
	eater.hunger += target.baseStats['maxWounds']
	if eater.hunger > 100:
		eater.hunger = 100
	
	## Healing
	if eater.baseStats['curWounds'] < eater.baseStats['maxWounds']:
		eater.baseStats['curWounds'] += round(target.baseStats['maxWounds'] * .1)
		
	## Progression
	var levelUpString = ''
	var statIncrease = false
	for stat in eater.growthRates:
		if checkGrowths(stat, true):
			statIncrease = true
			print('Raised ' + stat)
			eater.baseStats[stat] += 1
			levelUpString += stat + ' - '
	if statIncrease:
		dialogCanvas.processText(['Through wretched means ' + eater.characterName + ' engorged their ' + levelUpString])
	
func checkGrowths(stat, feast=false):
	var roll = randi() % 100 + 1
	if !feast:
		if growthRates[stat] >= roll:
			return true
		else:
			return false
	else:
		if (growthRates[stat]/4) >= roll:
			return true
		else:
			return false

func consumeTargetCorpse():
	currentAction = null
	game.get_node('cursor').hide()
	$audioContainer/feast.play()
	print('eating')
	actionDialog('feast')
	corpsesEaten += 1
	handleCannialismGains(target)
	
	var eater = game.selectedPlayerUnits[0]
	
	if target.isDiseased:
		eater.isDiseased = true
	else:
		if target.isPlayer:
			var roll = randi() % 100 + 1
			if roll <= 1:
				eater.isDiseased = true
		else:
			var roll = randi() % 100 + 1
			if roll <= 3:
				eater.isDiseased = true
	var roll = randi() % 100 + 1
	if roll <= 1 + corpsesEaten/2:
		eater.isFrenzied = true
	
	#if game.selectedPlayerUnits.size() > 0:
		#for i in range(game.selectedPlayerUnits.size() -1, -1, -1):
				##print(target)
				##print(game.selectedPlayerUnits[i].collider)
				#if target == game.selectedPlayerUnits[i].collider:
					#game.selectedPlayerUnits.remove_at(i)
	#for i in range(game.playerUnits.size() -1, -1, -1):
		#if target == game.playerUnits[i]:
			#game.playerUnits.remove_at(i)
	#for i in range(game.enemyUnits.size() -1, -1, -1):
		#if target == game.enemyUnits[i]:
			#game.enemyUnits.remove_at(i)
	#for i in range(game.allUnits.size() -1, -1, -1):
		#if target == game.allUnits[i]:
			#game.allUnits.remove_at(i)
			
	
	
	target.hide()
	target.hiddenCorpse = true
	target.get_node('CollisionShape2D').disabled = true
	
	
	#target.get_node('CollisionShape2D').queue_free()
	
## Currently recruits target unit if they are recruitable and plays dialog
func trySpeak():
	setTarget(game.getSelectedUnit())
	for unit in game.allUnits:
		if target == unit:
			if target.isRecruitable:
				target.isPlayer = true
				if target.aiState == 'hostile':
					target.aiState = 'fight'
				target.isRecruitable = false
				target.target = null
				target.get_node('visionCone').show()
				target.get_node('radialVision').show()
				## Iterate through and queue all of unit's recruitment dialog
				game.get_node('dialogCanvas').processText(target.recruitmentDialog,'pauseFocus',target.recruitmentScript,'high')
				## Iterate backwards through enemyUnits array and remove the recruited unit
				for i in range(game.enemyUnits.size() -1, -1, -1):
					if target == game.enemyUnits[i]:
						game.enemyUnits.remove_at(i)
						game.playerUnits.append(target)
			elif !target.isPlayer and !target.isRecruitable and !target.recruitmentDialog.is_empty():
				game.get_node('dialogCanvas').processText(target.recruitmentDialog,'pauseFocus',target.recruitmentScript,'high')
				
						
			else:
				print('Invalid')
			target = null

func actionDialog(actionType):
	if actionType == 'attack':
		if attackDialog:
			var roll = randi_range(0,100)
			if roll <= 5:
				var randomText = randi() % attackDialog.size()
				dialogCanvas.processText([characterName + ': ' + attackDialog[randomText]])
	elif actionType == 'feast':
		if feastDialog:
			var roll = randi_range(0,100)
			if roll <= 30:
				var randomText = randi() % feastDialog.size()
				dialogCanvas.processText([characterName + ': ' + feastDialog[randomText]])

func checkDeath():
	if isDead:
		if canDie:
			if !deathChecked:
				selected = false
				$selectionVisual.hide()
				set_collision_layer_value(1,false)
				set_collision_mask_value(1,false)
				set_collision_layer_value(2,true)
				set_collision_mask_value(2,true)
				if characterName != 'Sernas':
					for i in range(game.selectedPlayerUnits.size() -1, -1, -1):
						if self == game.selectedPlayerUnits[i]:
							game.selectedPlayerUnits.remove_at(i)
					for i in range(game.playerUnits.size() -1, -1, -1):
						if self == game.playerUnits[i]:
							game.playerUnits.remove_at(i)
					for i in range(game.enemyUnits.size() -1, -1, -1):
						if self == game.enemyUnits[i]:
							game.enemyUnits.remove_at(i)
					if self.characterName != 'Heir':
						for i in range(game.allUnits.size() -1, -1, -1):
							if self == game.allUnits[i]:
								game.allUnits.remove_at(i)
					deathChecked = true

			if emitDeathSignal == true and !deathSignalEmitted:
				deathSignal.emit(self)
				deathSignalEmitted = true
			
			target = null
			velocity = Vector2(0,0)
			baseStats['curWounds'] = 0
			modifiedStats['movement'] = 0
			modifiedStats['attackRange'] = 0
			modifiedStats['attackRate'] = 0
			$NavigationAgent2D.process_mode = Node.PROCESS_MODE_DISABLED
			if !isPlayer and !isNeutral:
				$enemyAISFM.process_mode = Node.PROCESS_MODE_DISABLED
			if isDead and characterName == 'Heir':
				gameOver.emit()
		else:
			if emitDeathSignal == true and !deathSignalEmitted:
				deathSignal.emit(self)
				deathSignalEmitted = true
			target = null
	else:
		pass

func setTarget(newTarget):
	target = newTarget
	
func moveToLocation(location):
	target = null
	agent.target_position = location ## Calculates the path to get from the current position to destination using NavigationAgent2d

func targetCheck(): ## Determines how far away the target is from a unit and do stuff
	if target != null and target.isDead and currentAction != 'feast':
		target = null
	elif target != null and target.isDead and currentAction == 'feast':
		var distance = global_position.distance_to(target.global_position)
		if distance <= modifiedStats['attackRange']:
			agent.target_position = global_position
			navigationComplete = false
			consumeTargetCorpse()
		else:
			agent.target_position = target.global_position
			navigationComplete = false
	if target != null and !target.isDead:
		var distance = global_position.distance_to(target.global_position)
		if distance <= modifiedStats['attackRange']:
			agent.target_position = global_position  ## Sets agent position to essentially stop moving
			if isPlayer and isTreating:
				pass
			else:
				if allowedToTarget:
					_tryAttackTarget()
					navigationComplete = false
		else:
			agent.target_position = target.global_position ## Sets agent position to the targets so the unit continues to pursue
			navigationComplete = false
			
func generateCorpse(): 
	if isPlayer:
		game.get_node('cutsceneManager').addAction('dialog',{'text':deathDialog,
											'script':[characterName]})
	#get_node('CollisionShape2D').disabled = true
	$audioContainer/death.play()
	print(characterName + ' has died!')
	isDead = true
	if canDie:
		sprite.texture = load("res://resources/sprites/corpse.png")
	## Cease all enemy AI
	## Player can no longer control it                     

func handleSpriteFacing():
	if !isPlayer:
		if velocity.x > 0:
			sprite.flip_h = true
		elif velocity.x < 0:
			sprite.flip_h = false
		

func _process(delta):
	targetCheck()
	handleSpriteFacing()
	checkDeath()
	_checkStatus()
	handleLevelUp()


	#if keepFocus:
	#	get_parent().get_parent().get_node('Camera2D').focusCamera(get_parent().get_parent().playerUnits[1])
	
	
func _physics_process(delta):

	
	if agent.is_navigation_finished() and !navigationComplete:  ## If intended destintation has been reached, then the code will end
		velocity = Vector2(0,0)
		#print('EMITTING')
		movementComplete.emit(self)
		navigationComplete = true
		return
	elif agent.is_navigation_finished():
		velocity = Vector2(0,0)
		return
	var direction = global_position.direction_to(agent.get_next_path_position())
	velocity = direction * (modifiedStats['movement']+(modifiedStats['agility']*2.5))
	## Reduces movement speed if unit is moving in a direction that they are not facing. Only left and right in this case
	if velocity.x > 0 and !sprite.flip_h:
		velocity = direction * (modifiedStats['movement']+(modifiedStats['agility']*2.5))/1.5
	if velocity.x < 0 and sprite.flip_h:
		velocity = direction * (modifiedStats['movement']+(modifiedStats['agility']*2.5))/1.5
	move_and_slide()
	

## Fires dialog from this character's idleDialog array and resets the idletimer
func _on_idle_timer_timeout():
	$idleTimer.wait_time = randi_range(120,480)
	if !idleDialog.is_empty() and isPlayer:
		var randomText = randi() % idleDialog.size()
		dialogCanvas.processText([characterName + ': ' + idleDialog[randomText]])

## Handles bleeding damage 
func _on_bleed_timer_timeout():

	if !baseStats['curWounds'] <= 0:
		baseStats['curWounds'] -= round(baseStats['maxWounds'] * .10)
		bleedMsg += 1
	if baseStats['curWounds'] <= 0:
		if !isDead:
			generateCorpse()
		
	if bleedMsg == 4:
		dialogCanvas.processText([characterName + ' is bleeding out!'])
		bleedMsg = 1


func _on_fatigue_timer_timeout():
	#print(fatigue)
	if velocity != Vector2(0,0):
		if fatigue <= 199:
			fatigue += 3.5
	elif velocity == Vector2(0,0):
		if fatigue >= 2:
			fatigue -= 1.75
