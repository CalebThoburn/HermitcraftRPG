extends Node2D

const CREATURES = {"boom_beatle": preload("res://scenes/boom_beatle.tscn")}
const THROWN_BLOCK = preload("res://scenes/thrown_block.tscn")
const WEB = preload("res://scenes/web.tscn")
const TB = preload("res://scenes/large_tid_bit.tscn")
const MAX_STACK = {"barrel": 64, "funnel": 8, "tip": 1}
const TB_TO_FRAME = ["barrel", "funnel", "glass_sole", "glass_top", "glass_center", "glass_bottom", "tip", "handle", "shaft_sole", "shaft_left", "shaft_center", "shaft_right", "computer", "wheel", "trigger_l", "trigger_t", "trigger_r", "trigger_b", "antenna_1", "antenna_2"]
const TB_INIT = Vector2(8, -2.5)
const TB_SPACING = 3
const TIME_BETWEEN_TICKS = .05

var pressed = [false, false, false]
var timeSinceTick = 0
var handlePos = Vector2(0, 0)
var blueprint = [
	[null, null, null, null], 
	[null, null, null, null], 
	[null, null, null, null], 
	[null, null, null, null]]

@onready var player = get_node("../../../")
@onready var tileMap = get_node("../../../../TileMap")

func _physics_process(delta):
	
	if Input.is_action_pressed("trigger_action1") and visible:
		pressed[0] = true
		
	if Input.is_action_pressed("trigger_action2") and visible:
		pressed[1] = true
		
	if Input.is_action_pressed("trigger_action3") and visible:
		pressed[2] = true
	
	timeSinceTick += delta
	
	if timeSinceTick > TIME_BETWEEN_TICKS and visible:
		timeSinceTick -= TIME_BETWEEN_TICKS
		_tick()

func _update():
	var item =  get_node("../../../HotBar").inventory[0][player.slot]
	
	blueprint = item.blueprint
	
	for child in get_children():
		child.queue_free()
	
	for row in range(blueprint.size()):
		
		for index in range(blueprint[row].size()):
			
			if item.blueprint[row][index] != null:
				
				if item.blueprint[row][index]["bit"] == "handle":
					handlePos = Vector2(row, index) * TB_SPACING
				
				var tidBit = TB.instantiate()
				
				if item.blueprint[row][index]["bit"] == "shaft":
					
					if _relitive(item.blueprint, row, -1)[index] != "shaft" and _relitive(blueprint, row, 1)[index] != "shaft":
						tidBit.frame = TB_TO_FRAME.find("shaft_sole")
					
					elif _relitive(item.blueprint, row, -1)[index] != "shaft":
						tidBit.frame = TB_TO_FRAME.find("shaft_left")
						
					elif _relitive(item.blueprint, row, 1)[index] != "shaft":
						tidBit.frame = TB_TO_FRAME.find("shaft_right")
					
					else:
						tidBit.frame = TB_TO_FRAME.find("shaft_center")
					
				elif item.blueprint[row][index]["bit"] == "trigger":
					blueprint[row][index]["powered"] = false
					tidBit.frame = TB_TO_FRAME.find("trigger_" + blueprint[row][index]["anchor"])
					
				elif blueprint[row][index]["bit"].left(8) == "computer":
					blueprint[row][index]["powered_1"] = false
					blueprint[row][index]["powered_2"] = false
					tidBit.frame = TB_TO_FRAME.find("computer")
					
				else:
					tidBit.frame = TB_TO_FRAME.find(blueprint[row][index])
				
				tidBit.position = TB_INIT + Vector2(row , index) * TB_SPACING
				add_child(tidBit)
	
	position = -handlePos

func _tick():
	
	var newBlueprint = blueprint
	
	for rowIndex in range(blueprint.size()):
		
		for bitIndex in range(blueprint[rowIndex].size()):
			
			var bit = newBlueprint[rowIndex][bitIndex]
			
			if bit != null:
				
				match bit["bit"]:
					
					"trigger":
						
						if pressed[bit["action"] - 1]:
							
							if typeof(bit["connectedTo"]) == 28:
								newBlueprint[bit["connectedTo"][0].x][bit["connectedTo"][0].y]["powerSockets"][bit["connectedTo"][1]] = true
								
							else:
								newBlueprint[bit["connectedTo"].x][bit["connectedTo"].y]["powered"] = true
							
							newBlueprint[rowIndex][bitIndex]["powered"] = false
					
					"funnel":
						
						if bit["powered"]:
							if _relitive(blueprint, rowIndex, -1) != null and blueprint[rowIndex - 1][bitIndex] != null and blueprint[rowIndex][bitIndex - 1]["bit"] == "barrel" and blueprint[rowIndex][bitIndex - 1]["count"] != 0:
								var output
								
								if bit["anchor"] == "b" and _relitive(blueprint[rowIndex], bitIndex , 1) != null:
									output = Vector2(0, 1)
									
								elif bit["anchor"] == "l" and _relitive(blueprint, rowIndex, -1) != null:
									output = Vector2(-1, 0)
									
								elif bit["anchor"] == "r" and _relitive(blueprint, rowIndex, 1) != null:
									output = Vector2(1, 0)
								
								if blueprint[rowIndex + output.x][bitIndex + output.y] != null and blueprint[rowIndex + output.x][bitIndex + output.y]["bit"] == "tip" and blueprint[rowIndex + output.x][bitIndex + output.y]["item"] == "air":
									newBlueprint[rowIndex + output.x][bitIndex + output.y]["item"] = blueprint[rowIndex][bitIndex - 1]["item"]
									
									newBlueprint[rowIndex][bitIndex - 1]["count"] -= 1
									
									if newBlueprint[rowIndex][bitIndex - 1]["count"] == 0:
										newBlueprint[rowIndex][bitIndex - 1]["item"] = "air"
								
							newBlueprint[rowIndex][bitIndex]["powered"] = false
							
					
					"tip":
						
						if bit["powered"]:
							var item = bit["item"]
							get_node("../Woosh").play()
							
							if tileMap.BLOCK_FRAME.has(item):
								
								var thrownBlock = THROWN_BLOCK.instantiate()
								thrownBlock.block = item
								thrownBlock.velocity = Vector2(300, 0).rotated(get_parent().rotation)
								
								if get_node("../../").scale.x == -1:
									thrownBlock.velocity = thrownBlock.velocity.rotated(PI)
									thrownBlock.velocity.y *= -1
								
								thrownBlock.velocity += get_node("../../../").velocity
								thrownBlock.position = to_global(TB_INIT + Vector2(rowIndex, bitIndex) * TB_SPACING)
								get_node("../../../../").add_child(thrownBlock)
								
							else:
								match item:
								
									"webs":
										var web = WEB.instantiate()
										web.position = to_global(TB_INIT + Vector2(rowIndex, bitIndex) * TB_SPACING)
										web.velocity = Vector2(300, 0).rotated(get_parent().rotation)
										
										if get_node("../../").scale.x == -1:
											web.velocity = web.velocity.rotated(PI)
											web.velocity.y *= -1
										
										web.velocity += get_node("../../../").velocity
										get_node("../../../../").add_child(web)
										
									"boom_beatle":
										var boom_beatle = CREATURES["boom_beatle"].instantiate()
										boom_beatle.position = to_global(TB_INIT + Vector2(rowIndex, bitIndex) * TB_SPACING)
										boom_beatle.velocity = Vector2(300, 0).rotated(get_parent().rotation)
										
										if get_node("../../").scale.x == -1:
											boom_beatle.velocity = boom_beatle.velocity.rotated(PI)
											boom_beatle.velocity.y *= -1
										
										boom_beatle.velocity += get_node("../../../").velocity
										get_node("../../../../").add_child(boom_beatle)
									
									_:
										get_node("../Woosh").stop()
							
							newBlueprint[rowIndex][bitIndex]["powered"] = false
							newBlueprint[rowIndex][bitIndex]["item"] = "air"
					
	pressed = [false, false, false]
	blueprint = newBlueprint

func _relitive(list, index, shift):
	
	if index + shift > -1 and index + shift < list.size():
		return list[index + shift]
		
	else:
		return null
