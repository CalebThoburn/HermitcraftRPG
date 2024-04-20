extends Sprite2D

var direction = null

func _process(delta):
	
	if Input.is_action_just_pressed("click") and direction != null:
		get_parent().info["direction"] = direction
		get_parent()._update_bit()
		get_node("../../").selecting = false
		queue_free()

func _on_left_mouse_entered():
	direction = -1

func _on_right_mouse_entered():
	direction = 1

func _on_mouse_exited():
	direction = null
