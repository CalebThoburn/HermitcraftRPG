extends Sprite2D

var anchor = null

func _process(delta):
	
	if Input.is_action_just_pressed("click") and anchor != null:
		get_parent().info["anchor"] = anchor
		get_parent()._update_bit()
		get_node("../../").selecting = false
		queue_free()
		

func _on_down_mouse_entered():
	anchor = "r"

func _on_left_mouse_entered():
	anchor = "l"

func _on_right_mouse_entered():
	anchor = "b"

func _on_mouse_exited():
	anchor = null
