extends CanvasLayer

var tween : Tween
var tween2 : Tween
var tween3 : Tween

func _ready():
	for unit in get_parent().allUnits:
		if unit.characterName == 'Heir':
			get_parent().get_node('Camera2D').focusCamera(unit,1.5)
	
	tween = create_tween()
	tween2 = create_tween()
	tween3 = create_tween()
	
	await tween.tween_property($"VBoxContainer/The Heir",'modulate:a',1,2.5)
	await tween.tween_property($"VBoxContainer/Has Fallen",'modulate:a',1,2.5)
	await tween.tween_property($"VBoxContainer/Their Bloodline",'modulate:a',1,2.5)
	await tween.tween_property($"VBoxContainer/Severed",'modulate:a',1,2.5)
	await tween.tween_property($"VBoxContainer/Severed",'modulate',Color.DARK_RED,2.5)
	tween2.tween_property($"VBoxContainer/HBoxContainer/Tempt Fate Once More?",'modulate:a',1,10)
	tween3.tween_property($"VBoxContainer/HBoxContainer/Begin Anew?",'modulate:a',1,10)

	

func _on_retry_button_down():
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_start_from_beginning_button_down():
	get_tree().change_scene_to_file("res://scenes/Opening.tscn")
