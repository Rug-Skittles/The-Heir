extends Node

@export var characterToTrigger : String
@export var multiCharacterTrigger : bool
@export var multiCharactersToTrigger : Array[String]

@export_category('Recruitment Event')
@export var recruitmentTrigger : bool
@export var recruitmentUnit : String

@export_category('Single scene properties')
@export var textToQueue : Array[String]
@export var textScript : Array[String]
@export var textState : String


@export_category('Cutscene Properties')
@export var isCutscene : bool = false
@export var actionTypeToProcess : Array[String]
@export var actionDataToProcess : Array[Dictionary]


var game = null
var cutsceneManager = null
var dialogCanvas = null

func _ready():
	cutsceneManager = get_node("/root/Game/cutsceneManager")
	game = get_node("/root/Game")
	dialogCanvas = get_node('/root/Game/dialogCanvas')

func _on_area_2d_body_entered(body):
	if recruitmentTrigger:
		for item in game.allUnits:
			if recruitmentUnit == item.characterName:
				item.isPlayer = true
				item.isRecruitable = false
				item.target = null
				item.get_node('visionCone').show()
				item.get_node('radialVision').show()
				for i in range(game.enemyUnits.size() -1, -1, -1):
					if item == game.enemyUnits[i]:
						game.enemyUnits.remove_at(i)
						game.playerUnits.append(item)
	if !multiCharacterTrigger:
		if body.characterName == characterToTrigger:
			if isCutscene:
				for i in range(actionTypeToProcess.size()):
					cutsceneManager.addAction(actionTypeToProcess[i],actionDataToProcess[i])
			else:
				dialogCanvas.processText(textToQueue,textState,textScript, 'high')

			queue_free()
	else:
		var characterIncrement = 0
		for unit in game.allUnits:
			for triggerUnit in multiCharactersToTrigger:
				if triggerUnit == unit.characterName:
					if !unit.isDead:
						characterIncrement += 1
						
		if characterIncrement == multiCharactersToTrigger.size():
			if isCutscene:
				for i in range(actionTypeToProcess.size()):
					cutsceneManager.addAction(actionTypeToProcess[i],actionDataToProcess[i])
			else:
				dialogCanvas.processText(textToQueue,textState,textScript,'high')
		else:
			pass
		queue_free()
		