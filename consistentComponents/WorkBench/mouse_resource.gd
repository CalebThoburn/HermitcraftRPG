extends Sprite2D

var tidbit = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position = get_global_mouse_position()
	
	if tidbit:
		frame = Global.tidbitsFirstFrame[tidbit]
		show()
	
	else:
		hide()
