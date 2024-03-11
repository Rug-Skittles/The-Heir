extends CanvasLayer


@onready var characterNameLabel = $rightStatsContainer/vContainer/characterNameLabel
@onready var spriteTexture = $rightStatsContainer/vContainer/spriteContainer/sprite
@onready var woundsVal = $rightStatsContainer/vContainer/woundsValueLabel
@onready var mightLabel = $rightStatsContainer/vContainer/statsMargin/statsHBox/leftStatVBoxValues/mightLabel
@onready var skillLabel = $rightStatsContainer/vContainer/statsMargin/statsHBox/leftStatVBoxValues/skillLabel
@onready var agiLabel = $rightStatsContainer/vContainer/statsMargin/statsHBox/leftStatVBoxValues/agiLabel
@onready var resLabel = $rightStatsContainer/vContainer/statsMargin/statsHBox/rightStatVBoxValues/resilienceLabel
@onready var survLabel = $rightStatsContainer/vContainer/statsMargin/statsHBox/rightStatVBoxValues/survivalLabel
@onready var rangeLabel = $rightStatsContainer/vContainer/statsMargin/statsHBox/rightStatVBoxValues/rangeLabel
@onready var hungerBar = $rightStatsContainer/vContainer/hungerBar

@onready var deathState = $rightStatsContainer/vContainer/MarginContainer/stateHBox/rightStateVBox2/deathState
@onready var frenzyState = $rightStatsContainer/vContainer/MarginContainer/stateHBox/rightStateVBox2/frenzyState
@onready var bleedingState = $rightStatsContainer/vContainer/MarginContainer/stateHBox/rightStateVBox2/bleedingState
@onready var hostilityState = $rightStatsContainer/vContainer/MarginContainer/stateHBox/leftStateVBox/hostilityState
@onready var diseaseState = $rightStatsContainer/vContainer/MarginContainer/stateHBox/leftStateVBox/diseaseState
@onready var fatigueState = $rightStatsContainer/vContainer/MarginContainer/stateHBox/leftStateVBox/fatigueState

@onready var speakAction = $rightStatsContainer/vContainer/MarginContainer2/VBoxContainer/HBoxContainer/speakAction
@onready var feastAction = $rightStatsContainer/vContainer/MarginContainer2/VBoxContainer/HBoxContainer/feastAction
@onready var treatToggle = $rightStatsContainer/vContainer/MarginContainer2/VBoxContainer/HBoxContainer/treatToggle

@onready var focusToggle = $rightStatsContainer/vContainer/MarginContainer2/VBoxContainer/HBoxContainer2/focusLabel
@onready var chaseToggle = $rightStatsContainer/vContainer/MarginContainer2/VBoxContainer/HBoxContainer2/chaseLabel
@onready var fightToggle = $rightStatsContainer/vContainer/MarginContainer2/VBoxContainer/HBoxContainer2/fightLabel


@onready var statValuesDisplay =   {'might':$rightStatsContainer/vContainer/statsMargin/statsHBox/leftStatVBoxValues/mightLabel, 
									'skill':$rightStatsContainer/vContainer/statsMargin/statsHBox/leftStatVBoxValues/skillLabel,
									'agility':$rightStatsContainer/vContainer/statsMargin/statsHBox/leftStatVBoxValues/agiLabel,
									'resilience':$rightStatsContainer/vContainer/statsMargin/statsHBox/rightStatVBoxValues/resilienceLabel,
									'survival':$rightStatsContainer/vContainer/statsMargin/statsHBox/rightStatVBoxValues/survivalLabel,
									'attackRange':$rightStatsContainer/vContainer/statsMargin/statsHBox/rightStatVBoxValues/rangeLabel}

signal buttonDown(button)

var game

func _ready():
	$rightStatsContainer/vContainer/MarginContainer/stateHBox/leftStateVBox/fatigueState.get_tooltip()
	game = get_node("/root/Game")

func removeStatInterface():
	visible = false

func changeStatColor(unit):
	for statKey in unit.collider.modifiedStats:
		if statValuesDisplay.has(statKey):
			if unit.collider.modifiedStats[statKey] > unit.collider.baseStats[statKey]:
				statValuesDisplay[statKey].add_theme_color_override("default_color",Color.DARK_GREEN)
			if unit.collider.modifiedStats[statKey] < unit.collider.baseStats[statKey]:
				statValuesDisplay[statKey].add_theme_color_override("default_color",Color.DARK_RED)
			if unit.collider.modifiedStats[statKey] == unit.collider.baseStats[statKey]:
				statValuesDisplay[statKey].add_theme_color_override("default_color",Color.WHITE)
			
func changeActiveStateColor(unit):
	if unit.collider.isDead:
		deathState.add_theme_color_override("default_color",Color.WHITE)
	else:
		deathState.add_theme_color_override("default_color",Color.DIM_GRAY)
	if unit.collider.isFatigued:
		fatigueState.add_theme_color_override("default_color",Color.WHITE)
	else:
		fatigueState.add_theme_color_override("default_color",Color.DIM_GRAY)
	if unit.collider.isPlayer:
		hostilityState.add_theme_color_override("default_color",Color.DIM_GRAY)
	else:
		hostilityState.add_theme_color_override("default_color",Color.WHITE)
	if unit.collider.isDiseased:
		diseaseState.add_theme_color_override("default_color",Color.WHITE)
	else:
		diseaseState.add_theme_color_override("default_color",Color.DIM_GRAY)
	if unit.collider.isBleeding:
		bleedingState.add_theme_color_override("default_color",Color.WHITE)
	else:
		bleedingState.add_theme_color_override("default_color",Color.DIM_GRAY)
	if unit.collider.isFrenzied:
		frenzyState.add_theme_color_override("default_color",Color.WHITE)
	else:
		frenzyState.add_theme_color_override("default_color",Color.DIM_GRAY)

	if unit.collider.isPlayer:
		if unit.collider.aiState == 'chase':
			chaseToggle.add_theme_color_override("default_color",Color.WHITE)
		else:
			chaseToggle.add_theme_color_override("default_color",Color.DIM_GRAY)
		if unit.collider.aiState == 'fight':
			fightToggle.add_theme_color_override("default_color", Color.WHITE)
		else:
			fightToggle.add_theme_color_override("default_color", Color.DIM_GRAY)
			
	if get_parent().get_node('Camera2D').keepFocus:
		focusToggle.add_theme_color_override("default_color", Color.WHITE)
	else:
		focusToggle.add_theme_color_override("default_color", Color.DIM_GRAY)
		
	if unit.collider.isPhysician:
		treatToggle.text = '[center]Treat'
		speakAction.text = 'Speak'
	else:
		treatToggle.text = ''
		speakAction.text = '             Speak'
	if unit.collider.isTreating:
		treatToggle.add_theme_color_override("default_color", Color.WHITE)
	else:
		treatToggle.add_theme_color_override("default_color", Color.DIM_GRAY)
		
func revealStats(unit):
	visible = true
	characterNameLabel.text = '[center]' + unit.collider.characterName
	spriteTexture.texture = unit.collider.sprite.texture
	woundsVal.text =  '[center]' + str(unit.collider.baseStats['curWounds']) + ' / ' + str(unit.collider.baseStats['maxWounds'])
	mightLabel.text = '[center]' + str(unit.collider.modifiedStats['might'])
	skillLabel.text = '[center]' + str(unit.collider.modifiedStats['skill'])
	agiLabel.text =   '[center]' + str(unit.collider.modifiedStats['agility'])
	resLabel.text =   '[center]' + str(unit.collider.modifiedStats['resilience'])
	survLabel.text =  '[center]' + str(unit.collider.modifiedStats['survival'])
	rangeLabel.text = '[center]' + str(unit.collider.modifiedStats['attackRange'])
	hungerBar.value = unit.collider.hunger
	changeActiveStateColor(unit)
	changeStatColor(unit)
	if !unit.collider.isPlayer:
		$rightStatsContainer/vContainer/skillsLabel.hide()
		speakAction.hide()
		feastAction.hide()
		treatToggle.hide()
		chaseToggle.hide()
		fightToggle.hide()
		focusToggle.hide()
	else:
		$rightStatsContainer/vContainer/skillsLabel.show()
		speakAction.show()
		feastAction.show()
		treatToggle.show()
		chaseToggle.show()
		fightToggle.show()
		focusToggle.show()
	




func _on_speak_action_button_down():
	
	buttonDown.emit('speak')

func _on_feast_action_button_down():
	buttonDown.emit('feast')



func _on_focus_button_button_down():
	buttonDown.emit('focus')
	
func _on_chase_button_button_down():
	buttonDown.emit('chase')

func _on_fight_button_button_down():
	buttonDown.emit('fight')

func _on_treat_button_button_down():
	buttonDown.emit('treat')	



