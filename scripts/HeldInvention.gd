extends Node2D

const MAX_STACK = {"barrel": 64, "funnel": 8, "tip": 1}
const TB = preload("res://scenes/large_tid_bit.tscn")
const TB_TO_FRAME = ["barrel", "funnel", "glass_sole", "glass_top", "glass_center", "glass_bottom", "air", "tip", "handle", "shaft_sole", "shaft_left", "shaft_center", "shaft_right", "air", "lever_right_off", "lever_right_on", "lever_down_off", "lever_down_on", "lever_up_off", "lever_up_on", "lever_left_on", "lever_left_off"]
const TB_INIT = Vector2(8, -2.5)
const TB_SPACING = 3

var handlePos = Vector2(0, 0)
var leverActivations = []
var items = [
	[["air", 0], ["air", 0], ["air", 0], ["air", 0]], 
	[["air", 0], ["air", 0], ["air", 0], ["air", 0]], 
	[["air", 0], ["air", 0], ["air", 0], ["air", 0]], 
	[["air", 0], ["air", 0], ["air", 0], ["air", 0]]]
var blueprint = [
	[null, null, null, null], 
	[null, null, null, null], 
	[null, null, null, null], 
	[null, null, null, null]]

@onready var player = get_node("../../../")
@onready var tileMap = get_node("../../../../TileMap")

func _physics_process(delta):
	
	if Input.is_action_just_pressed("lever_action1") and visible:
		_use(1)
		
	if Input.is_action_just_pressed("lever_action2") and visible:
		_use(2)
		
	if Input.is_action_just_pressed("lever_action3") and visible:
		_use(3)
	
func _update():
	
	items = get_node("../../../HotBar").inventory[0][player.slot].items
	blueprint = get_node("../../../HotBar").inventory[0][player.slot].blueprint
	leverActivations = get_node("../../../HotBar").inventory[0][player.slot].activations
	
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
					
				elif blueprint[row][index] == "lever":
					pass
				else:
					tidBit.frame = TB_TO_FRAME.find(blueprint[row][index])
				
				tidBit.position = TB_INIT + Vector2(row , index) * TB_SPACING
				add_child(tidBit)
	
	position = -handlePos

func _use(press):
	
	for event in leverActivations:
		var poweredCoords
		
		if event[0] == press:
			poweredCoords = event[1]
			
		else:
			continue
		
		var action = blueprint[poweredCoords.x][poweredCoords.y]
		
		match action:
			
			"tip":
				var item = items[poweredCoords.x][poweredCoords.y][0]
				
				if tileMap.PLACEABLE_ITEMS.has(item):
					items[poweredCoords.x][poweredCoords.y][1] -= 1
					
					if items[poweredCoords.x][poweredCoords.y][1] == 0:
						items[poweredCoords.x][poweredCoords.y] = ["air", 0]
					
					tileMap._place(item, tileMap.local_to_map(to_global(TB_INIT + Vector2(leverActivations[0][1][0], leverActivations[0][1][1]) * TB_SPACING + Vector2(16, 0))))
			
			"funnel":
				
				if items[poweredCoords.x][poweredCoords.y - 1][0] != "air":
					var item = items[poweredCoords.x][poweredCoords.y - 1][0]
					
					items[poweredCoords.x][poweredCoords.y - 1][1] -= 1
					
					if items[poweredCoords.x][poweredCoords.y - 1][1] == 0:
						items[poweredCoords.x][poweredCoords.y - 1] = ["air", 0]
					
					if MAX_STACK.keys().has(blueprint[poweredCoords.x][poweredCoords.y + 1]):
						
						if items[poweredCoords.x][poweredCoords.y + 1][0] == "air":
							items[poweredCoords.x][poweredCoords.y + 1] = [item, 1]
							
						elif items[poweredCoords.x][poweredCoords.y + 1][0] == item and items[poweredCoords.x][poweredCoords.y + 1][1] < MAX_STACK[blueprint[poweredCoords.x][poweredCoords.y + 1]]:
							items[poweredCoords.x][poweredCoords.y + 1][1] += 1
						

func _relitive(list, index, shift):
	
	if index + shift > -1 and index + shift < list.size():
		return list[index + shift]
		
	else:
		return [null, null, null, null]
