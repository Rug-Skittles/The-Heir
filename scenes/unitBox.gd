extends CanvasLayer


var unitContainerArray

func _ready():
	unitContainerArray = get_tree().get_nodes_in_group("unitContainer")
	for unit in get_tree().get_nodes_in_group("units"):
		unit.connect('deathSignal',onPlayerUnitDeath)

func _process(delta):
	if get_parent().get_node("interface").visible:
		$Control.position.x = get_parent().get_node("interface").get_node('rightStatsContainer').position.x
	else:
		$Control.position.x = get_parent().get_node("interface").get_node('rightStatsContainer').position.x + 320
	
	for i in range(get_parent().playerUnits.size()):
		if !get_parent().playerUnits[i].isDead:
			unitContainerArray[i].get_node('TextureButton').texture_normal = get_parent().playerUnits[i].get_node('Sprite2D').texture
			unitContainerArray[i].show()
			$Control/unitBoxPanel.size.y = 64 * get_parent().playerUnits.size()

func onPlayerUnitDeath(unit):
	for item in unitContainerArray:
		if item.get_node('TextureButton').texture_normal == unit.get_node('Sprite2D').texture:
			item.hide()
		item.hide()

func getSelectedUnit(unit):
	get_parent()._unselectUnit
	unit.selected = true
	get_parent().unitToReveal = unit
	unit.toggleSelectionVisual(true)
	get_parent().get_node("Camera2D").focusCamera(unit,1)
	get_parent().selectedPlayerUnits.append(unit)

func _on_texture_button_pressed():
	if get_parent().playerUnits.size() >= 1:
		getSelectedUnit(get_parent().playerUnits[0])
	
func _on_texture_button_pressed_1():
	if get_parent().playerUnits.size() >= 2:
		getSelectedUnit(get_parent().playerUnits[1])
	
func _on_texture_button_pressed_2():
	if get_parent().playerUnits.size() >= 3:
		getSelectedUnit(get_parent().playerUnits[2])

func _on_texture_button_pressed_3():
	if get_parent().playerUnits.size() >= 4:
		getSelectedUnit(get_parent().playerUnits[3])

func _on_texture_button_pressed_4():
	if get_parent().playerUnits.size() >= 5:
		getSelectedUnit(get_parent().playerUnits[4])

func _on_texture_button_pressed_5():
	if get_parent().playerUnits.size() >= 6:
		getSelectedUnit(get_parent().playerUnits[5])

func _on_texture_button_pressed_6():
	if get_parent().playerUnits.size() >= 7:
		getSelectedUnit(get_parent().playerUnits[6])

func _on_texture_button_pressed_7():
	if get_parent().playerUnits.size() >= 8:
		getSelectedUnit(get_parent().playerUnits[7])

func _on_texture_button_pressed_8():
	if get_parent().playerUnits.size() >= 9:
		getSelectedUnit(get_parent().playerUnits[8])

func _on_texture_button_pressed_9():
	if get_parent().playerUnits.size() >= 10:
		getSelectedUnit(get_parent().playerUnits[9])

func _on_texture_button_pressed_10():
	if get_parent().playerUnits.size() >= 11:
		getSelectedUnit(get_parent().playerUnits[10])
