extends Unit

@export var sightRange : float = 500
@onready var gameManager = get_node("/root/Game")

@export var aiDisabled : bool = false

@export var startingState : String = 'CHASE'
@export var stateList : Array[String]
@export_category('Patrol Parameters')
var homePosition : Vector2
@export var maxPatrolRange : float = 500
@export var minWaitTime : float = 1.0
@export var maxWaitTime : float = 2.0
@export_category('Flee Parameters')
@export var fleeDistance : float = 300
@export var allySearchDistance : float = 1000
@export_category('Guard Parameters')
@export var guardDistance : float = 300

var recruitmentDialog = []

func _process(delta):
	#print(aiDisabled)
	#if target == null:
		#for unit in gameManager.playerUnits:
			#if unit.isDead != true:
				#var distance = global_position.distance_to(unit.global_position)
				#if distance <= sightRange:
					#setTarget(unit)
			
	_checkStatus()
	targetCheck()
	handleSpriteFacing()
	checkDeath()
