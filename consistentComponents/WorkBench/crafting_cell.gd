extends Area2D

var coords: Vector2i
var info = {"tidbit": null}
var dirIndex = 0 # index, because it only records the index of dir in list, will have to fetch actual dir when making mechanism

var mouseIn = false

func _physics_process(delta: float) -> void:
	# set the frame of the tidbit if shown
	if info["tidbit"]:
		$Sprite2D.frame = Global.tidbitsFirstFrame[info["tidbit"]] + dirIndex
		$Sprite2D.show()
	
	else:
		$Sprite2D.hide()
	
	# set the tidbit on click
	if Input.is_action_just_pressed("click") and mouseIn:
		info["tidbit"] = get_parent().get_node("Mouse").tidbit
		
		if Global.tidbitsInfo.has(info["tidbit"]) and Global.tidbitsInfo[info["tidbit"]].has("dirs"):
			info["dir"] = Global.tidbitsInfo[info["tidbit"]]["dirs"][0]
		
		get_parent().currentBlueprint[coords] = info
		
		if info["tidbit"] == null:
			get_parent().currentBlueprint.erase(coords)
		
		dirIndex = 0
		get_parent().get_node("Mouse").tidbit = null
	
	# modulate tidbit direction on rclick
	if Input.is_action_just_pressed("rclick") and mouseIn and Global.tidbitsInfo.has(info["tidbit"])  and Global.tidbitsInfo[info["tidbit"]].has("dirs"):
		
		if dirIndex == Global.tidbitsInfo[info["tidbit"]]["dirs"].size() - 1:
			dirIndex = 0
		
		else:
			dirIndex += 1
		
		info["dir"] = Global.tidbitsInfo[info["tidbit"]]["dirs"][dirIndex]
		get_parent().currentBlueprint[coords] = info

func _on_mouse_entered() -> void:
	mouseIn = true

func _on_mouse_exited() -> void:
	mouseIn = false
