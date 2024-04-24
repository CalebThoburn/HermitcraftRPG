extends Camera2D

const TRANSITION_DURATION = 1.0

var startTime = 0.0
var origin = Vector2(0, 0)
var destination = Vector2(0, 0)
var originZoom = Vector2(4, 4)
var destinedZoom = Vector2(4, 4)

func _process(delta):
	position = (destination - origin) * easeOutQuint() + origin
	zoom = (destinedZoom - originZoom) * easeOutQuint() + originZoom

func easeOutQuint():
	
	var progress = (Time.get_ticks_msec() / 1000.0 - startTime) / TRANSITION_DURATION
	
	if 1.0 - pow(1.0 - progress, 5.0) > 1:
		return 1
		
	else:
		return 1.0 - pow(1.0 - progress, 5.0)
