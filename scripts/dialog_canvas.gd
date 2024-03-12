extends CanvasLayer

const CHAR_READ_RATE = 0.035

@onready var textboxContainer = $textboxContainer
@onready var textboxGraphic = $textboxContainer/graphic
@onready var textContent = $textboxContainer/internalMargin/text
var dialogStyle: StyleBoxFlat = createDialogStyle()

var cutsceneManager = null
var audioContainer = null

enum State {
	WAITING,
	READY,
	TYPING,
	PAUSE_TYPING,
	FOCUS_TYPING,
	PAUSE_FOCUS_TYPING,
	FINISHED,
}

var currentState = State.READY
var currentSpeaker 

var readyPause = false
var readyPauseFocus = false

var priorityTextQueue = []
var priorityScriptQueue = []
var textQueue = []
var scriptQueue = []

var recievedUnit = null

var tween : Tween
var textTimer : Timer

func createDialogStyle() -> StyleBoxFlat: 
	var stylebox = StyleBoxFlat.new() 
	stylebox.bg_color = Color(0, 0, 0, 0) 
	stylebox.border_width_bottom = 2 
	stylebox.border_width_left = 2
	stylebox.border_width_right = 2 
	stylebox.border_width_top = 2
	stylebox.border_color = Color(255, 255, 255, 255) 
	stylebox.corner_detail = 2
	stylebox.corner_radius_top_left = 24
	stylebox.corner_radius_top_right = 24
	stylebox.corner_radius_bottom_left = 6
	stylebox.corner_radius_bottom_right = 6
	stylebox.shadow_color = Color(0, 0, 0, 255)
	stylebox.shadow_size = 8
	
	return stylebox


## Function to display dialog based on unit
## Random chance when doing action, attack, feasting
## Random low chance for idle
## Display 



# Called when the node enters the scene tree for the first time.
func _ready():
	tween = create_tween()
	cutsceneManager = get_parent().get_node('cutsceneManager')
	audioContainer = get_node('root/Game/audioContainer')
	hideTextbox()
	textboxGraphic.add_theme_stylebox_override('panel',dialogStyle)
	textboxGraphic.get_theme_stylebox('panel').shadow_color = Color.BLACK
	textboxGraphic.get_theme_stylebox('panel').border_color = Color.WHITE
	
	## Connects all units singal and listens for emission
	for unit in get_tree().get_nodes_in_group("units"):
		unit.connect('movementComplete',onUnitMovementComplete)
		unit.connect('attackComplete',onUnitAttackComplete)
	
	
func _process(delta):
	#print(textQueue)
	#print(priorityTextQueue)
	#print(currentState)
	match currentState:
		State.READY:
			get_parent().get_node('currentWorld').get_node('unitContainer').process_mode = Node.PROCESS_MODE_INHERIT
			#print('Ready?')
			if !priorityTextQueue.is_empty():
				if tween:
					tween.kill()
				displayText('high')
			elif !textQueue.is_empty() and priorityTextQueue.is_empty():
				print('DISPLAYING')
				displayText(null)
			else:
				readyPause = false
				readyPauseFocus = false
				if !tween.is_running():
					get_parent().get_node('Camera2D').unfocusCamera()
		State.TYPING:
			if Input.is_action_just_pressed("skipDialog"):
				textContent.percent_visible = 1.0
				#tween.pause()
				tween.custom_step(100.0)
				#changeState(State.FINISHED)
		State.PAUSE_TYPING:
			if Input.is_action_just_pressed("skipDialog"):
				textContent.percent_visible = 1.0
				#tween.pause()
				tween.custom_step(100.0)
				#changeState(State.FINISHED)
			if currentSpeaker != null:
				#print(currentSpeaker)
				currentSpeaker.get_node('selectionVisual').show()
			get_parent().get_node('currentWorld').get_node('unitContainer').process_mode = Node.PROCESS_MODE_DISABLED
		State.PAUSE_FOCUS_TYPING:
			if Input.is_action_just_pressed("skipDialog"):
				textContent.visible_ratio = 1
				#tween.pause()
				
				tween.custom_step(100.0)
				
				#changeState(State.FINISHED)
			if currentSpeaker != null:
				#print(currentSpeaker)
				currentSpeaker.get_node('selectionVisual').show()
			get_parent().get_node('Camera2D').focusCamera(currentSpeaker,1.5)
			get_parent().get_node('currentWorld').get_node('unitContainer').process_mode = Node.PROCESS_MODE_DISABLED
		State.FINISHED:
			changeState(State.READY)

func processText(textInput, state=null, script=null, priority=null):
	if priority != null:
		changeState(State.READY)
	if script == null:
		for text in textInput:
			queueText(text,state,null,priority)
	elif script != null:
		for i in range(textInput.size()):
			queueText(textInput[i],state,script[i],priority)
				
func hideTextbox():
	textContent.text = ''
	textboxContainer.hide()
	
func showTexbox():
	textboxContainer.show()
	
func queueText(nextText, state = null, script = null, priority = null):
	if priority != null:
		priorityTextQueue.push_back(nextText)
		#print('PR TEXT Q')
		#print(priorityTextQueue)
		if script != null:
			priorityScriptQueue.push_back(script)
			#print('PR SCRIPT Q')
			#print(priorityScriptQueue)
	elif priority == null:
		textQueue.push_back(nextText)
		#print('TEXT Q')
		#print(textQueue)
		if script != null:
			scriptQueue.push_back(script)
			#print('SCRIPT Q')
			#print(scriptQueue)
	if state == 'pause':
		readyPause = true
	elif state == 'pauseFocus':
		readyPauseFocus = true

	
func displayText(priority):
	var textToAdd = ''
	var lineSpeaker = ''
	
	
	if !priorityTextQueue.is_empty():
		#print('PRIORITY TEXT')
		textToAdd = priorityTextQueue.pop_front()
	else:
		#print('POPPING')
		textToAdd = textQueue.pop_front()
	if readyPause:
		changeState(State.PAUSE_TYPING)
	elif readyPauseFocus:
		changeState(State.PAUSE_FOCUS_TYPING)
	else:
		changeState(State.TYPING)
	if priorityScriptQueue != []:
		lineSpeaker = priorityScriptQueue.pop_front()
		textContent.text = lineSpeaker + ': ' + textToAdd
		for unit in get_parent().allUnits:
			if unit.characterName == lineSpeaker:
				if currentSpeaker != null:
					currentSpeaker.get_node('selectionVisual').hide()
				currentSpeaker = unit
				#print(currentSpeaker)
	elif scriptQueue != []:
		lineSpeaker = scriptQueue.pop_front()
		textContent.text = lineSpeaker + ': ' + textToAdd
		for unit in get_parent().allUnits:
			if unit.characterName == lineSpeaker:
				if currentSpeaker != null:
					currentSpeaker.get_node('selectionVisual').hide()
				currentSpeaker = unit
				#print(currentSpeaker)
				
				
	else:
		textContent.text = textToAdd
	textContent.visible_ratio = 0
	showTexbox()
	#ween.kill()
	tween = create_tween()
	#for i in textToAdd:
		#await get_tree().create_timer(CHAR_READ_RATE).timeout
		#$"../audioContainer/textScroll".play()
		#print(audioContainer)
		
	tween.tween_property(textContent,'visible_ratio',1,len(textToAdd)*CHAR_READ_RATE)
	tween.tween_property(textboxContainer,'modulate',Color(0,0,0,0),3)
	tween.connect("finished", onTweenFinished)
	
	
	
func onTweenFinished():
	
	print('TWEEN HAS FINISHED!!!')
	changeState(State.FINISHED)
	#get_parent().get_node('unitContainer').process_mode = Node.PROCESS_MODE_INHERIT
	#print(get_parent().get_node('unitContainer').process_mode)
	
	if priorityTextQueue.size() == 0:
		if cutsceneManager.processing == true:
			cutsceneManager.processing = false
	
func changeState(newState):
	currentState = newState
	match currentState:
		State.WAITING:
			print('Dialog box WAIT')
			Node.PROCESS_MODE_DISABLED
		State.READY:
			Node.PROCESS_MODE_INHERIT
			print('Dialog box READY')
		State.TYPING:
			print('Dialog box TYPING')
		State.PAUSE_TYPING:
			print('Dialog box PAUSE TYPING')
		State.PAUSE_FOCUS_TYPING:
			print('Dialog box PAUSE FOCUS TYPING')
		State.FINISHED:
			get_parent().get_node('currentWorld').get_node('unitContainer').process_mode = Node.PROCESS_MODE_INHERIT
			print(get_parent().get_node('currentWorld').get_node('unitContainer').process_mode)
			if currentSpeaker != null:
				currentSpeaker.get_node('selectionVisual').hide()
			print('Dialog box FINISHED')
			textboxContainer.modulate = Color(1,1,1,1)
			hideTextbox()


func _on_cutscene_manager_start_action():
	changeState(State.WAITING)

func onUnitMovementComplete(unit):
	if unit == recievedUnit:
		#print('CHANGING TO READY')
		changeState(State.READY)
		cutsceneManager.processing = false
		
func onUnitAttackComplete(unit):
	if unit == recievedUnit:
		cutsceneManager.processing = false

func _on_cutscene_manager_send_unit(unit):
	recievedUnit = unit
	#print('UNIT RECIEVED')
