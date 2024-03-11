extends Control

var attackRadius : int

func _draw():
	if get_parent().selected:
		draw_arc(Vector2(0,0), attackRadius, 0, 7, 30, Color.WHITE, 2, false)

func _process(delta):
	attackRadius = get_parent().modifiedStats['attackRange']
	queue_redraw()
