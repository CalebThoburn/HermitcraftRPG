extends Node2D

const CREATURES = {"boom_beatle": preload("res://scenes/boom_beatle.tscn")}
const THROWN_BLOCK = preload("res://scenes/thrown_block.tscn")
const WEB = preload("res://scenes/web.tscn")
const TB = preload("res://scenes/large_tid_bit.tscn")
const MAX_STACK = {"barrel": 64, "funnel": 8, "tip": 1}
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
				get_node("../Woosh").play()
				
				if tileMap.BLOCK_FRAME.has(item):
					
					var thrownBlock = THROWN_BLOCK.instantiate()
					thrownBlock.block = item
					thrownBlock.velocity = Vector2(300, 0).rotated(get_parent().rotation)
					
					if get_node("../../").scale.x == -1:
						thrownBlock.velocity = thrownBlock.velocity.rotated(PI)
						thrownBlock.velocity.y *= -1
					
					thrownBlock.velocity += get_node("../../../").velocity
					thrownBlock.position = to_global(TB_INIT + Vector2(leverActivations[0][1][0], leverActivations[0][1][1]) * TB_SPACING)
					get_node("../../../../").add_child(thrownBlock)
					
				else:
					match item:
					
						"webs":
							var web = WEB.instantiate()
							web.position = to_global(TB_INIT + Vector2(leverActivations[0][1][0], leverActivations[0][1][1]) * TB_SPACING)
							web.velocity = Vector2(300, 0).rotated(get_parent().rotation)
							
							if get_node("../../").scale.x == -1:
								web.velocity = web.velocity.rotated(PI)
								web.velocity.y *= -1
							
							web.velocity += get_node("../../../").velocity
							get_node("../../../../").add_child(web)
							
						"boom_beatle":
							var boom_beatle = CREATURES["boom_beatle"].instantiate()
							boom_beatle.position = to_global(TB_INIT + Vector2(leverActivations[0][1][0], leverActivations[0][1][1]) * TB_SPACING)
							boom_beatle.velocity = Vector2(300, 0).rotated(get_parent().rotation)
							
							if get_node("../../").scale.x == -1:
								boom_beatle.velocity = boom_beatle.velocity.rotated(PI)
								boom_beatle.velocity.y *= -1
							
							boom_beatle.velocity += get_node("../../../").velocity
							get_node("../../../../").add_child(boom_beatle)
						
						_:
							get_node("../Woosh").stop()
					
				items[poweredCoords.x][poweredCoords.y][1] -= 1
					
				if items[poweredCoords.x][poweredCoords.y][1] == 0:
					items[poweredCoords.x][poweredCoords.y] = ["air", 0]
			
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
