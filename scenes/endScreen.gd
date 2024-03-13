extends CanvasLayer

var tween

func _ready():
	tween = create_tween()
	tween.tween_property($Control/text1,'visible_ratio',1,3)
	tween.tween_property($Control/text2,'visible_ratio',1,3)
	tween.tween_property($Control/text3,'visible_ratio',1,3)
	tween.tween_property($Control/text4,'visible_ratio',1,3)
	tween.tween_property($Control/text5,'visible_ratio',1,3)
	tween.tween_property($Control/text6,'visible_ratio',1,3)

