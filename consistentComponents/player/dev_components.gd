extends Node2D

func _ready() -> void:
	Global.DEV_COMPS = self


func _process(delta: float) -> void:
	
	# NULL is the lowest 'survival' action, anything greater is also a 'survival' action
	if Global.playerAction >= Global.Actions.NULL:
		hide()
	
	else:
		show()
