extends Area2D

var collision = true

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	
	if Global.playerAction == Global.Actions.EDIT and event.is_action_pressed("click"):
		get_parent()._switch_edit_mode(get_parent().EditMode.COLLISION)
	
	if Global.playerAction == Global.Actions.EDIT and event.is_action_pressed("rclick"):
		$Collision.frame = ($Collision.frame + 1) % 2
		collision = !collision
