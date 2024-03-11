extends Node
class_name CutsceneAction
var type: String
var data: Dictionary
	
func __init__(type: String, data: Dictionary):
	self.type = type
	self.data = data 
