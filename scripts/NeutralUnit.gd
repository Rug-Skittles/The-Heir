extends Unit

@onready var selectionVisual : Sprite2D = get_node("selectionVisual")
@onready var visionCone = $visionCone

@export var sightRange : float = 300
@onready var gameManager = get_node("/root/Game")

@export var recruitmentDialog : Array[String]
@export var recruitmentScript : Array[String]

@export var aiDisabled : bool = true

var hungerMsg = 2

@export var aiState = 'passive'
var recruited : bool = false
var treatmentTarget = null

func handleAiState():
	
	if aiState == 'hostile':
		for unit in gameManager.playerUnits:
			#print(unit)
			#print(global_position.distance_to(unit.global_position))
			if global_position.distance_to(unit.global_position) <= sightRange and !unit.isDead and unit != self:
				#print('GETTING THIS')
				
				target = unit
				#print(target)
	
	if aiState == 'chase' and target == null and velocity == Vector2(0,0):
		var bodiesInView = []
		var enemiesInView = []
		for body in visionCone.get_node('Area2D').get_overlapping_bodies():
			if !body.isPlayer and !body.isDead and body != self:
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
			for unit in game.playerUnits:
				if unit != self and treatmentTarget == null:
					if unit.isBleeding || unit.timeSinceLastTreatment <= Time.get_unix_time_from_system() - 60 and unit.baseStats['curWounds'] < unit.baseStats['maxWounds']:
						if global_position.distance_to(unit.global_position) <= modifiedStats['attackRange']:
							#print('TREATING!')
							unit.get_node('treatmentBarTimer').stop()
							agent.target_position = unit.global_position
							unit.agent.target_position = unit.global_position
							treatmentTarget = unit
							if $treatmentTimer.is_stopped():
								$treatmentTimer.timeout.connect(_on_treatment_timer_timeout)
								$treatmentTimer.start(4.0)
								

				elif treatmentTarget != null:
					agent.target_position = treatmentTarget.global_position
					treatmentTarget.agent.target_position = treatmentTarget.global_position		
		else:
			aiState = 'passive'
	else:
		isTreating = false
					
	
	pass

func _ready():
	dialogCanvas = get_node("/root/Game/dialogCanvas")
	add_to_group("units")
	
	#isPlayer = false
	agent = $NavigationAgent2D
	sprite = $Sprite2D
	
	isNeutral = true
	
	game = get_node("/root/Game")
	
	
	game.allUnits.append(self)
	
	if isPlayer:
		game.playerUnits.append(self)
	else:
		game.enemyUnits.append(self)
		
	## Initialize stats
	initStats()
	$radialVision.visible = false
	$visionCone.visible = false

func toggleSelectionVisual(toggle):
	selectionVisual.visible = toggle

func handleSpriteFacing():
	if visionCone.global_rotation_degrees > 0:
		sprite.flip_h = false
	elif visionCone.global_rotation_degrees <0:
		sprite.flip_h = true
	
## Every x time from hungerTick reduces the unit's hunger by an amount modified by their survival.
## Additionally more hunger will be reduced if the unit is moving.
func _on_timer_timeout():
	if isPlayer:
		var survivalModifier = modifiedStats['survival'] * 0.105
		if velocity != Vector2(0,0):
			hunger -= (1.00 - survivalModifier)
		else:
			hunger -= (0.7 - survivalModifier)
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

func _process(delta):
	
	
	targetCheck()
	handleAiState()
	handleSpriteFacing()
	checkDeath()
	_checkStatus()
	handleLevelUp()
	if isFrenzied and isPlayer:
		aiState = 'chase'


func _on_treatment_timer_timeout():
	treatmentTarget.get_node('treatmentBarTimer').start()
	treatmentTarget.timeSinceLastTreatment = Time.get_unix_time_from_system()
	treatmentTarget.isBleeding = false
	treatmentTarget.baseStats['curWounds'] += modifiedStats['survival']
	if treatmentTarget.baseStats['curWounds'] > treatmentTarget.baseStats['maxWounds']:
		treatmentTarget.baseStats['curWounds'] = treatmentTarget.baseStats['maxWounds']
	$treatmentTimer.stop()
	
	dialogCanvas.processText(['Treatment on ' + treatmentTarget.characterName + ' complete!'])
	treatmentTarget = null
