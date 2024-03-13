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
@onready var treatToggle = $rightStatsContainer/vContainer/MarginContainer4/VBoxContainer/HBoxContainer/treatToggle

@onready var focusToggle = $rightStatsContainer/vContainer/MarginContainer4/VBoxContainer/HBoxContainer2/focusLabel
@onready var chaseToggle = $rightStatsContainer/vContainer/MarginContainer4/VBoxContainer/HBoxContainer2/chaseLabel
@onready var fightToggle = $rightStatsContainer/vContainer/MarginContainer4/VBoxContainer/HBoxContainer2/fightLabel

@onready var statusToggle = $rightStatsContainer/vContainer/MarginContainer4/VBoxContainer/HBoxContainer/chaseLabel

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
	for statKey in unit.modifiedStats:
		if statValuesDisplay.has(statKey):
			if unit.modifiedStats[statKey] > unit.baseStats[statKey]:
				statValuesDisplay[statKey].add_theme_color_override("default_color",Color.DARK_GREEN)
			if unit.modifiedStats[statKey] < unit.baseStats[statKey]:
				statValuesDisplay[statKey].add_theme_color_override("default_color",Color.DARK_RED)
			if unit.modifiedStats[statKey] == unit.baseStats[statKey]:
				statValuesDisplay[statKey].add_theme_color_override("default_color",Color.WHITE)
			
func changeActiveStateColor(unit):
	if unit.isDead:
		deathState.add_theme_color_override("default_color",Color.WHITE)
	else:
		deathState.add_theme_color_override("default_color",Color.DIM_GRAY)
	if unit.isFatigued:
		fatigueState.add_theme_color_override("default_color",Color.WHITE)
	else:
		fatigueState.add_theme_color_override("default_color",Color.DIM_GRAY)
	if unit.isPlayer:
		hostilityState.add_theme_color_override("default_color",Color.DIM_GRAY)
	else:
		hostilityState.add_theme_color_override("default_color",Color.WHITE)
	if unit.isDiseased:
		diseaseState.add_theme_color_override("default_color",Color.WHITE)
	else:
		diseaseState.add_theme_color_override("default_color",Color.DIM_GRAY)
	if unit.isBleeding:
		bleedingState.add_theme_color_override("default_color",Color.WHITE)
	else:
		bleedingState.add_theme_color_override("default_color",Color.DIM_GRAY)
	if unit.isFrenzied:
		frenzyState.add_theme_color_override("default_color",Color.WHITE)
	else:
		frenzyState.add_theme_color_override("default_color",Color.DIM_GRAY)

	if unit.isPlayer:
		if unit.aiState == 'chase':
			chaseToggle.add_theme_color_override("default_color",Color.WHITE)
		else:
			chaseToggle.add_theme_color_override("default_color",Color.DIM_GRAY)
		if unit.aiState == 'fight':
			fightToggle.add_theme_color_override("default_color", Color.WHITE)
		else:
			fightToggle.add_theme_color_override("default_color", Color.DIM_GRAY)
			
	if get_parent().get_node('Camera2D').keepFocus:
		focusToggle.add_theme_color_override("default_color", Color.WHITE)
	else:
		focusToggle.add_theme_color_override("default_color", Color.DIM_GRAY)
		
	if unit.isPhysician:
		treatToggle.text = '                        Treat'
		statusToggle.text = '[center]   Show Status'
	else:
		treatToggle.text = ''
		statusToggle.text = '[center]                Show Status'
	if unit.isTreating:
		treatToggle.add_theme_color_override("default_color", Color.WHITE)
	else:
		treatToggle.add_theme_color_override("default_color", Color.DIM_GRAY)
		
func revealStats(unit):
	visible = true
	characterNameLabel.text = '[center]' + unit.characterName
	spriteTexture.texture = unit.sprite.texture
	woundsVal.text =  '[center]' + str(unit.baseStats['curWounds']) + ' / ' + str(unit.baseStats['maxWounds'])
	mightLabel.text = '[center]' + str(unit.modifiedStats['might'])
	skillLabel.text = '[center]' + str(unit.modifiedStats['skill'])
	agiLabel.text =   '[center]' + str(unit.modifiedStats['agility'])
	resLabel.text =   '[center]' + str(unit.modifiedStats['resilience'])
	survLabel.text =  '[center]' + str(unit.modifiedStats['survival'])
	rangeLabel.text = '[center]' + str(unit.modifiedStats['attackRange'])
	hungerBar.value = unit.hunger
	$rightStatsContainer/vContainer/TreatmentTimeBar.value = unit.get_node('treatmentBarTimer').time_left
	changeActiveStateColor(unit)
	changeStatColor(unit)
	if !unit.isPlayer:
		$rightStatsContainer/vContainer/skillsLabel.hide()
		$rightStatsContainer/vContainer/skillsLabel2.hide()
		#statusToggle.hide()
		speakAction.hide()
		feastAction.hide()
		treatToggle.hide()
		chaseToggle.hide()
		fightToggle.hide()
		focusToggle.hide()
	else:
		$rightStatsContainer/vContainer/skillsLabel.show()
		$rightStatsContainer/vContainer/skillsLabel2.show()
		#statusToggle.show()
		speakAction.show()
		feastAction.show()
		treatToggle.show()
		chaseToggle.show()
		fightToggle.show()
		focusToggle.show()
	


func _input(event):
	if Input.is_action_just_pressed("speak"):
		buttonDown.emit('speak')
	if Input.is_action_just_pressed("feast"):
		buttonDown.emit('feast')
	if Input.is_action_just_pressed("treat"):
		buttonDown.emit('treat')
	if Input.is_action_just_pressed("fight"):
		buttonDown.emit('fight')
	if Input.is_action_just_pressed("chase"):
		buttonDown.emit('chase')
	if Input.is_action_just_pressed("focus"):
		buttonDown.emit('focus')
	if Input.is_action_just_pressed("cycleUnitBack"):
		buttonDown.emit('cycleUnitBack')
	if Input.is_action_just_pressed("cycleUnitForward"):
		buttonDown.emit('cycleUnitForward')


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



