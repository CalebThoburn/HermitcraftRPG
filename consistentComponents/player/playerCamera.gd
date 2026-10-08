extends Camera2D

const ZOOM_SPEED = 1.2 # the factore by which to zoom in and out

func _input(event):
	
	# if devmode is for placing and scroll, zoom in or out
	if Global.playerAction == Global.Actions.PLACE and event is InputEventPanGesture:
		zoom *= pow(ZOOM_SPEED, event.delta.x)
