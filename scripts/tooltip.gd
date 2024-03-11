extends Control


func _make_custom_tooltip(tooltipText):
	var tooltip = preload("res://scenes/tooltipNew.tscn").instantiate()
	tooltip.custom_minimum_size = Vector2(428,0)
	tooltip.text = tooltipText
	print(tooltip)
	return tooltip


