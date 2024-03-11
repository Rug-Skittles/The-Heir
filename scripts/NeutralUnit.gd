extends Unit

@onready var selectionVisual : Sprite2D = get_node("selectionVisual")
@onready var visionCone = $visionCone

@export var sightRange : float = 300
@onready var gameManager = get_node("/root/Game")

@export var recruitmentDialog : Array[String]
@export var recruitmentScript : Array[String]

@export var aiDisabled : bool = true
var isNeutral : bool = true
var aiState = 'passive'
var recruited : bool = false
var treatmentTarget = null

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
	
	if aiState == 'fight' and target == null and velocity == Vector2(0,0):
		var bodiesInView = []
		var enemiesInView = []
		for body in visionCone.get_node('Area2D').get_overlapping_bodies():
			if !body.isPlayer and !body.isDead:
				enemiesInView.append(body)
		for unit in enemiesInView:
			if unit.target == self:
				target = unit
				
	
	if aiState == 'treat':
		isTreating = true
		for unit in game.playerUnits:
			if unit != self and treatmentTarget == null:
				if unit.isBleeding || unit.timeSinceLastTreatment <= Time.get_unix_time_from_system() - 60 and unit.baseStats['curWounds'] < unit.baseStats['maxWounds']:
					if global_position.distance_to(unit.global_position) <= modifiedStats['attackRange']:
						#print('TREATING!')
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
		isTreating = false
					
	
	pass

func _ready():
	dialogCanvas = get_node("/root/Game/dialogCanvas")
	add_to_group("units")
	
	isPlayer = false
	agent = $NavigationAgent2D
	sprite = $Sprite2D
	
	game = get_node("/root/Game")
	audioContainer = get_node("/root/Game/audioContainer")
	
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
		var survivalModifier = modifiedStats['survival'] * 0.12
		if velocity != Vector2(0,0):
			hunger -= 1.5 - survivalModifier
		else:
			hunger -= 1.2 - survivalModifier

func _process(delta):
	
	handleAiState()
	targetCheck()
	handleSpriteFacing()
	checkDeath()
	_checkStatus()


func _on_treatment_timer_timeout():
	treatmentTarget.timeSinceLastTreatment = Time.get_unix_time_from_system()
	treatmentTarget.isBleeding = false
	treatmentTarget.baseStats['curWounds'] += modifiedStats['survival']
	if treatmentTarget.baseStats['curWounds'] > treatmentTarget.baseStats['maxWounds']:
		treatmentTarget.baseStats['curWounds'] = treatmentTarget.baseStats['maxWounds']
	$treatmentTimer.stop()
	dialogCanvas.processText('Treatment on ' + treatmentTarget.characterName + ' complete!')
	treatmentTarget = null
