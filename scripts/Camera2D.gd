extends Camera2D

const ZOOMRATE = 5.0
const MINZOOM = 0.5
const MAXZOOM = 1.5
const ZOOMINCREMENT = 0.1

var targetZoom = 1.0

var keepFocus : bool = false

const DOUBLETAP_DELAY = .25
var doubletap_time = DOUBLETAP_DELAY
var last_keycode = 0

func _process(delta):
	doubletap_time -= delta
	if keepFocus and get_parent().get_node('cutsceneManager').processing and get_parent().get_node('cutsceneManager').lastMovedUnit != null:
		focusCamera(get_parent().get_node('cutsceneManager').lastMovedUnit, zoom.x)
	if keepFocus and get_parent().selectedPlayerUnits.size() > 0:
		focusCamera(get_parent().selectedPlayerUnits[0], zoom.x)
	var direction = Vector2()
	if Input.is_action_pressed("moveCameraNorth"):
		direction.y -= 1
	if Input.is_action_pressed("moveCameraEast"):
		direction.x += 1
	if Input.is_action_pressed("moveCameraSouth"):
		direction.y += 1
	if Input.is_action_pressed("moveCameraWest"):
		direction.x -= 1
	
	position += direction.normalized() * 700 * delta

	
	
	
#func _input(event):
	#if event is InputEventMouseButton and event.is_pressed():
		#if event.button_index == MOUSE_BUTTON_LEFT:
			#if last_keycode == event.button_index and doubletap_time >= 0: 
				#last_keycode = 0
				#if get_parent().selectedPlayerUnits:
					#focusCamera(get_parent().selectedPlayerUnits[0].collider)
					#
			#else:
				#last_keycode = event.button_index
			#doubletap_time = DOUBLETAP_DELAY
		
func focusCamera(target, zoomFloat):
	zoom = Vector2(zoomFloat,zoomFloat)
	position.x = (target.global_position.x - ((get_viewport().size.x / 2)/zoom.x)) 
	position.y = target.global_position.y - ((get_viewport().size.y / 2)/zoom.y)

func unfocusCamera():
	zoom = Vector2(1,1)
	


#func _unhandled_input(event: InputEvent):
	#if event is InputEventMouseMotion:
		#if event.button_mask == MOUSE_BUTTON_MASK_MIDDLE:
			#position -= event.relative * zoom
	#if event is InputEventMouseButton:
		#if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			#zoomOut()
			#
		#if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			#zoomIn()
			
			
func zoomOut():
	targetZoom = max(targetZoom + ZOOMINCREMENT, MAXZOOM)
	set_physics_process(true)
	
func zoomIn():
	targetZoom = max(targetZoom - ZOOMINCREMENT, MINZOOM)
	set_physics_process(true)
	
func _physics_process(delta):
	zoom = lerp(zoom, targetZoom * Vector2.ONE, ZOOMRATE * delta)
	set_physics_process(not is_equal_approx(zoom.x, targetZoom))
	#if Input.is_action_pressed("moveCameraNorth"):
		#position.y -= 30
	#if Input.is_action_pressed("moveCameraEast"):
		#position.x += 30
	#if Input.is_action_pressed("moveCameraSouth"):
		#position.y += 30
	#if Input.is_action_pressed("moveCameraWest"):
		#position.x -= 30


	
