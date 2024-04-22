extends Area2D

func _on_area_entered(area):
	
	if area.name == "MouseDetectorGrid":
		get_node("../../").collisionPointsTouchingCursor += 1

func _on_area_exited(area):
	
	if area.name == "MouseDetectorGrid":
		get_node("../../").collisionPointsTouchingCursor -= 1
