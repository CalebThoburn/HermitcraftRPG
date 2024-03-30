extends Node2D

const TB = preload("res://scenes/large_tid_bit.tscn")
const TB_TO_FRAME = ["barrel", "funnel", "glass_sole", "glass_top", "glass_center", "glass_bottom", "air", "tip", "handle", "shaft_sole", "shaft_left", "shaft_center", "shaft_right", "air", "lever_right_off", "lever_right_on", "lever_down_off", "lever_down_on", "lever_up_off", "lever_up_on", "lever_left_on", "lever_left_off"]
const TB_INIT = Vector2(8, -2.5)
const TB_SPACING = 3

var handlePos = Vector2(0, 0)
var leverActivations = [[3, 2]]
var items = [
	[["air", 0], ["air", 0], ["air", 0], ["air", 0]], 
	[["air", 0], ["air", 0], ["air", 0], ["air", 0]], 
	[["air", 0], ["air", 0], ["air", 0], ["air", 0]], 
	[["air", 0], ["air", 0], ["dirt", 0], ["air", 0]]]
var blueprint = [
	[null, null, null, null], 
	[null, null, null, null], 
	[null, null, null, null], 
	[null, null, null, null]]

@onready var player = get_node("../../../")
@onready var tileMap = get_node("../../../../TileMap")

func _physics_process(delta):
	
	if Input.is_action_just_pressed("right_click") and visible:
		_use()

func _update():
	
	for child in get_children():
		child.queue_free()
	
	for row in range(blueprint.size()):
		
		for index in range(blueprint[row].size()):
			
			if blueprint[row][index] == "handle":
				handlePos = Vector2(row, index) * TB_SPACING
				
			if blueprint[row][index] != null:
				var tidBit = TB.instantiate()
				
				if blueprint[row][index] == "shaft":
					
					if _relitive(blueprint, row, -1)[index] != "shaft" and _relitive(blueprint, row, 1)[index] != "shaft":
						tidBit.frame = TB_TO_FRAME.find("shaft_sole")
					
					elif _relitive(blueprint, row, -1)[index] != "shaft":
						tidBit.frame = TB_TO_FRAME.find("shaft_left")
						
					elif _relitive(blueprint, row, 1)[index] != "shaft":
						tidBit.frame = TB_TO_FRAME.find("shaft_right")
					
					else:
						tidBit.frame = TB_TO_FRAME.find("shaft_center")
					
				else:
					tidBit.frame = TB_TO_FRAME.find(blueprint[row][index])
				
				tidBit.position = TB_INIT + Vector2(row , index) * TB_SPACING
				add_child(tidBit)
	
	position = -handlePos

func _use():
	
	for poweredCoords in leverActivations:
		var action = blueprint[poweredCoords[0]][poweredCoords[1]]
		
		if action == "tip":
			var item = items[poweredCoords[0]][poweredCoords[1]][0]
			
			if tileMap.PLACEABLE_ITEMS.has(item):
				
				tileMap._place(item, tileMap.local_to_map(to_global(TB_INIT + Vector2(leverActivations[0][0], leverActivations[0][1]) * TB_SPACING + Vector2(16, 0))))

func _relitive(list, index, shift):
	
	if index + shift > -1 and index + shift < list.size():
		return list[index + shift]
		
	else:
		return [null, null, null, null]
