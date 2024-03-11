extends Control


func _input(event):
	var tween = create_tween()
	tween.tween_property($Camera2D,'position:y',1000,5)
	
	
	

	get_tree().change_scene_to_file("res://scenes/game.tscn")
