extends Node2D

var allLights

var tweenArray = []
var maxEnergyArray = []

func _ready():
	allLights = get_tree().get_nodes_in_group('lights')
	for light in range(allLights.size()):
		maxEnergyArray.append(allLights[light].energy)
		var tween = create_tween()
		tweenArray.append(tween)
		tween.connect("finished", onTweenFinished)
		tween.tween_property(allLights[light],'energy',maxEnergyArray[light],3)
		#tween.tween_property(light.get_node('PointLight2D'),'energy',0,10)
		#tween.set_loops(5)
		#tween.tween_property(light.get_node('PointLight2D'),'energy',.5,10)
		#light.get_node('PointLight2D').energy = 20

func onTweenFinished():
	for tween in range(tweenArray.size() -1, -1, -1):
		tweenArray[tween].kill()
		tweenArray.remove_at(tween)
		
		#for i in range(game.allUnits.size() -1, -1, -1):
		#if target == game.allUnits[i]:
			#game.allUnits.remove_at(i)

func _process(delta):
	#print(tweenArray.size())
	#print(allLights[0].energy)
	if allLights[0].energy == maxEnergyArray[0]:
		for light in allLights:
			var tween = create_tween()
			tweenArray.append(tween)
			tween.connect("finished", onTweenFinished)
			tween.tween_property(light,'energy',0.2,3)
	elif allLights[0].energy <= 0.21:
		for light in range(allLights.size()):
			var tween = create_tween()
			tweenArray.append(tween)
			tween.connect("finished", onTweenFinished)
			tween.tween_property(allLights[light],'energy',maxEnergyArray[light],3)
		


