extends Sprite2D

var mouseIn = false

func _process(_delta: float) -> void:
	
	if mouseIn and Input.is_action_pressed("click") and get_node("../../").mode == get_node("../../").EditMode.RETEXTURE:
		# store changes so they can be undone, or applied to file when saved, but only if the change is different than the last
		# doesn't bother checking last change if no changes are saved
		if get_parent().changes.size() == 0 or !(get_parent().changes[-1]["pixel"] == self and get_parent().changes[-1]["newColor"] == get_node("../../ColorPicker").color):
			get_parent().changes.append({"pixel": self, "oldColor": modulate, "newColor": get_node("../../ColorPicker").color})
			modulate = get_node("../../ColorPicker").color

func _on_area_2d_mouse_entered() -> void:
	mouseIn = true

func _on_area_2d_mouse_exited() -> void:
	mouseIn = false
