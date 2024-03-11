extends Node2D

## Placed in a seperate node in order to draw over graphics rather than in Game where they would be below.



func _draw():
	if get_parent().dragSelect:
		draw_rect(Rect2(((get_parent().dragStart+($"../Camera2D".position*$"../Camera2D".zoom))/$"../Camera2D".zoom), ((get_viewport().get_mouse_position()) - get_parent().dragStart)/$"../Camera2D".zoom),
				Color.YELLOW, false, 2.0)	
		
##			
##
##		drag start - (100,100)
##		mouse pos - (300,300)
##		camera pos - (-50,-50)
##	    camera zoom - 2
##
##
##		realStart - (50,50)




func _process(delta):
	#print('DRAG START: ' + str(get_parent().dragStart+$"../Camera2D".position/$"../Camera2D".zoom))
	#print('RECT DIMENSIONS: ' + str((get_viewport().get_mouse_position() - get_parent().dragStart)/$"../Camera2D".zoom))
	queue_redraw()
	
