extends Sprite2D

var tidbit
var mouseIn = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("click") and mouseIn:
		get_parent().get_node("Mouse").tidbit = tidbit

func _on_area_2d_mouse_entered() -> void:
	mouseIn = true

func _on_area_2d_mouse_exited() -> void:
	mouseIn = false
