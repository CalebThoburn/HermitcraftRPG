extends Sprite2D

const FLASH_TIME = .5

var flashTime = 0.0
var action = 0

func _process(delta):
	flashTime += delta
	
	if flashTime > FLASH_TIME:
		flashTime = 0
		if frame == 1:
			frame = 0
		
		else:
			frame = 1
	
	if Input.is_action_just_pressed("click") and action != 0:
		get_parent().action = action
		queue_free()

func _on_action_1_mouse_entered():
	action = 1

func _on_action_2_mouse_entered():
	action = 2

func _on_action_3_mouse_entered():
	action = 3

func _mouse_exited():
	action = 0
