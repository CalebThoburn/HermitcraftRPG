extends Sprite2D

const WHEEL_DIRECTION_SELECT = preload("res://scenes/direction_select.tscn")
const ACTION_SELECT = preload("res://scenes/lever_action_select.tscn")
const FUNNEL_SELECT = preload("res://scenes/funnel_direction_select.tscn")
const WIRE = preload("res://scenes/wire.tscn")
const ITEM = preload("res://scenes/collected_item.tscn")
const RESOURCE = preload("res://scenes/tinker_resource.tscn")
const INITIAL_X = -9
const INITIAL_Y = -13
const SPACING = 9
const OUTPUT_POS = Vector2(37, 14)
const WIRE_OFFSET = {"wheel": Vector2(0, 0), "antenna_1": Vector2(0, 6), "antenna_2": Vector2(0, 6), "tip": Vector2(-5, 1), "funnel": Vector2(0, -2), "b": Vector2(0, 6), "t": Vector2(0, -3), "l": Vector2(-5, 1), "r": Vector2(4, 1)}
const WIRE_ENDS = ["tip", "funnel", "antenna_1", "antenna_2", "wheel"]

var output
var mouseInOutput = false
var mouseInGrid = false
var mouseInResources = false
var mouseItem = null
var resources = [
	[null, null, null, null], 
	[null, null, null, null],
	[null, null, null, null],
	[null, null, null, null]]
var grid = [
	[null, null, null, null], 
	[null, null, null, null], 
	[null, null, null, null], 
	[null, null, null, null]]
var wiresByEnd = [
	[null, null, null, null], 
	[null, null, null, null], 
	[null, null, null, null], 
	[null, null, null, null]]
var unlockedItems = ["wheel", "tip", "computer_flip", "antenna_1", "handle", "funnel", "computer_xor", "antenna_2", "trigger", "barrel", "computer_and"]
var wire = null
var mouseIn = false
var selecting = false

func _process(delta):
	
	if mouseInGrid or mouseInOutput or mouseInResources:
		mouseIn = true
	
	else:
		mouseIn = false
	
	var mouseGridPos = round((get_local_mouse_position() - Vector2(INITIAL_X, INITIAL_Y)) / SPACING)
	
	if !selecting:
		
		if get_node("../../Player/HotBar").mouseItem == null:
			
			if Input.is_action_just_pressed("right_click") and mouseInGrid:
				
				if wire == null:
					
					if grid[mouseGridPos.x][mouseGridPos.y] != null and grid[mouseGridPos.x][mouseGridPos.y].info["bit"] == "trigger" and grid[mouseGridPos.x][mouseGridPos.y].info["connectedTo"] == null:
						wire = WIRE.instantiate()
						wire.position = Vector2(0, 0)
						wire.origin = mouseGridPos * SPACING + Vector2(INITIAL_X, INITIAL_Y)
						wire.color = 0
						wire.position += WIRE_OFFSET[grid[mouseGridPos.x][mouseGridPos.y].info["anchor"]]
						wire.from = mouseGridPos
						add_child(wire)
					
					elif grid[mouseGridPos.x][mouseGridPos.y] != null and grid[mouseGridPos.x][mouseGridPos.y].info["bit"].left(7) == "antenna" and grid[mouseGridPos.x][mouseGridPos.y].info["connectedTo"] == null:
						wire = WIRE.instantiate()
						wire.position = Vector2(0, 0)
						wire.origin = mouseGridPos * SPACING + Vector2(INITIAL_X, INITIAL_Y)
						wire.color = 0
						wire.position += WIRE_OFFSET[grid[mouseGridPos.x][mouseGridPos.y].info["bit"]]
						wire.from = mouseGridPos
						add_child(wire)
					
				elif grid[mouseGridPos.x][mouseGridPos.y] != null and WIRE_ENDS.has(grid[mouseGridPos.x][mouseGridPos.y].info["bit"]):
					grid[wire.from.x][wire.from.y].info["connectedTo"] = mouseGridPos
					wire.to = mouseGridPos
					wire.attached = true
					wire.end = mouseGridPos * SPACING + WIRE_OFFSET[grid[mouseGridPos.x][mouseGridPos.y].info["bit"]] + Vector2(INITIAL_X, INITIAL_Y)
					
					if grid[wire.from.x][wire.from.y].info["bit"] == "trigger":
						wire.end -= WIRE_OFFSET[grid[wire.from.x][wire.from.y].info["anchor"]]
						
					else:
						WIRE_OFFSET[grid[wire.from.x][wire.from.y].info["bit"]]
					
					wiresByEnd[wire.to.x][wire.to.y] = wire
					wire = null
					output._update_invention()
					
				else:
					wire.queue_free()
					wire = null
			
			if Input.is_action_just_pressed("click") and mouseInResources:
				
				if mouseItem != null:
					mouseItem.queue_free()
				
				elif resources[mouseGridPos.y][-(mouseGridPos.x + 2)] != null:
					mouseItem = RESOURCE.instantiate()
					mouseItem.row = -1
					mouseItem.index = 0
					mouseItem.info["bit"] = resources[mouseGridPos.y][-(mouseGridPos.x + 2)].info["bit"]
					_set_defaults(mouseItem)
					add_child(mouseItem)
			
			if Input.is_action_just_pressed("click") and mouseInGrid:
				var transferingItem = mouseItem
				
				if mouseItem != null:
					transferingItem.row = mouseGridPos.x
					transferingItem.index = mouseGridPos.y
					
					if transferingItem.info["bit"] == "trigger":
						
						if _relitive(grid[mouseGridPos.x], mouseGridPos.y, 1) != null:
							transferingItem.info["anchor"] = "b"
							
						elif _relitive(grid, mouseGridPos.x, 1)[mouseGridPos.y] != null:
							transferingItem.info["anchor"] = "r"
							
						elif _relitive(grid, mouseGridPos.x, -1)[mouseGridPos.y] != null:
							transferingItem.info["anchor"] = "l"
							
						elif _relitive(grid[mouseGridPos.x], mouseGridPos.y, -1) != null:
							transferingItem.info["anchor"] = "t"
						
						else:
							transferingItem.info["anchor"] = "b"
						
						transferingItem._update_bit()
						
						if transferingItem.info["action"] == null:
							var actionSelect = ACTION_SELECT.instantiate()
							transferingItem.add_child(actionSelect)
							selecting = true
						
					elif transferingItem.info["bit"] == "funnel" and transferingItem.info["anchor"] == null:
						var directionSelect = FUNNEL_SELECT.instantiate()
						transferingItem.add_child(directionSelect)
						selecting = true
					
					elif transferingItem.info["bit"] == "wheel" and transferingItem.info["direction"] == null:
						var directionSelect = WHEEL_DIRECTION_SELECT.instantiate()
						transferingItem.add_child(directionSelect)
						selecting = true
					
				mouseItem = grid[mouseGridPos.x][mouseGridPos.y]
				
				if grid[mouseGridPos.x][mouseGridPos.y] != null:
					mouseItem.row = -1
					
					if mouseItem.info["connectedTo"] != null:
						wiresByEnd[mouseItem.info["connectedTo"].x][mouseItem.info["connectedTo"].y].queue_free()
						wiresByEnd[mouseItem.info["connectedTo"].x][mouseItem.info["connectedTo"].y] = null
						mouseItem.info["connectedTo"] = null
					
					elif wiresByEnd[mouseGridPos.x][mouseGridPos.y] != null:
						var deadWire = wiresByEnd[mouseGridPos.x][mouseGridPos.y]
						grid[deadWire.from.x][deadWire.from.y].info["connectedTo"] = null
						deadWire.queue_free()
						wiresByEnd[mouseGridPos.x][mouseGridPos.y] = null
					
					if mouseItem.info["bit"] == "trigger" and  mouseItem.info["action"] == 0:
						mouseItem.get_node("LeverActionSelect").queue_free()
					
					elif mouseItem.info["bit"] == "funnel" and mouseItem.info["anchor"] == null:
						mouseItem.get_node("FunnelDirectionSelect").queue_free()
				
				grid[mouseGridPos.x][mouseGridPos.y] = transferingItem
				output._update_invention()
			
			if Input.is_action_just_pressed("click") and mouseInOutput and _type(grid) != "invaild":
				
				for rowIndex in range(grid.size()):
					
					for bitIndex in range(grid[rowIndex].size()):
						
						if grid[rowIndex][bitIndex] != null:
							output.blueprint[rowIndex][bitIndex] = grid[rowIndex][bitIndex].info
				
				get_node("../../Player/HotBar").mouseItem = output
				output.reparent(get_node("../../Player/HotBar"))
				output.item = _type(grid)
				_reset_board()
				_set_resources()
			
		elif mouseInGrid and Input.is_action_just_pressed("click") and get_node("../../Player/HotBar").mouseItem.item == "invention":
			
			_reset_board()
			_set_resources()
			
			var inv = get_node("../../Player/HotBar").mouseItem
			var blueprint = inv.blueprint
			for row in range(blueprint.size()):
				
				for index in range(blueprint[row].size()):
					
					if blueprint[row][index] != null:
						var resource = RESOURCE.instantiate()
						grid[row][index] = resource
						resource.row = row
						resource.index = index
						resource.info = blueprint[row][index]
						
						if resource.info["connectedTo"] != null:
							var wire = WIRE.instantiate()
							wire.position = Vector2(0, 0) + WIRE_OFFSET[resource.info["anchor"]]
							wire.from = Vector2(row, index)
							wire.to = resource.info["connectedTo"]
							wire.end = wire.to * SPACING + WIRE_OFFSET[blueprint[wire.to.x][ wire.to.y]["bit"]] + Vector2(INITIAL_X, INITIAL_Y) - WIRE_OFFSET[resource.info["anchor"]]
							wire.origin = wire.from * SPACING + Vector2(INITIAL_X, INITIAL_Y)
							wire.attached = true
							wire.color = 0
							
							if blueprint[wire.to.x][wire.to.y]["anchor"] == null:
								wire.position += WIRE_OFFSET[blueprint[wire.to.x][wire.to.y]["bit"]]
								
							else:
								wire.position += WIRE_OFFSET[blueprint[wire.to.x][wire.to.y]["anchor"]]
							wire.attached = true
							add_child(wire)
						
						add_child(resource)
				
			inv.queue_free()
			get_node("../../Player/HotBar").mouseItem = null
			output._update_invention()
						
		elif mouseInGrid and Input.is_action_just_pressed("click") and grid[mouseGridPos.x][mouseGridPos.y] != null and grid[mouseGridPos.x][mouseGridPos.y].info["bit"] == "barrel":
			
			var info = grid[mouseGridPos.x][mouseGridPos.y].info.duplicate(true)
			
			grid[mouseGridPos.x][mouseGridPos.y].info["item"] = get_node("../../Player/HotBar").mouseItem.item
			grid[mouseGridPos.x][mouseGridPos.y].info["count"] = get_node("../../Player/HotBar").mouseItem.count
			get_node("../../Player/HotBar").mouseItem.item = info["item"]
			get_node("../../Player/HotBar").mouseItem.count = info["count"]
			get_node("../../Player/HotBar").mouseItem.get_node("ItemSprite").frame = get_node("../../Player/HotBar").mouseItem.ITEMS.find(get_node("../../Player/HotBar").mouseItem.item)
			
	if Input.is_action_just_pressed("left") or Input.is_action_just_pressed("right"):
		_close()

func _set_defaults(mouseItem):
	
	mouseItem.info.merge({"powered": false,"anchor": null, "connectedTo": null, "action": null, "item": "air", "count": 0, "direction": null})
	var bit = mouseItem.info["bit"]

func _type(blueprint):
	
	if blueprint == [[null, null, null, null], [null, null, null, null], [null, null, null, null], [null, null, null, null]]:
		return "invalid"
		
	else:
		
		var type = "mechanism"
		
		for row in grid:
			
			for bit in row:
				
				if bit != null:
					
					if bit.info["bit"] == "handle":
						
						type = "invention"
		return type

func _close():
	get_node("../../Player").crafting = false
	hide()
	_reset_board()

func _open():
	selecting = false
	get_node("../../Player").crafting = true
	show()
	_reset_board()
	_set_resources()

func _set_resources():
	
	for bit in unlockedItems:
		var resource = RESOURCE.instantiate()
		resource.row = -2 - floor(unlockedItems.find(bit) / 4)
		resource.index = unlockedItems.find(bit) - floor(unlockedItems.find(bit) / 4) * 4
		resource.info["bit"] = bit
		_set_defaults(resource)
		resources[resource.index][floor(unlockedItems.find(bit) / 4)] = resource
		add_child(resource)

func _reset_board():
	
	grid = [
		[null, null, null, null], 
		[null, null, null, null], 
		[null, null, null, null], 
		[null, null, null, null]]
	wiresByEnd = [
		[null, null, null, null], 
		[null, null, null, null], 
		[null, null, null, null], 
		[null, null, null, null]]

	for child in get_children():
		
		if !child.is_class("Area2D"):
			
			child.queue_free()
	
	output = ITEM.instantiate()
	output.row = -1
	output.index = 0
	output.item = "invention"
	output.blueprint = grid
	add_child(output)

func _on_mouse_detector_grid_mouse_entered():
	mouseInGrid = true

func _on_mouse_detector_grid_mouse_exited():
	mouseInGrid = false

func _on_mouse_detector_resources_mouse_entered():
	mouseInResources = true

func _on_mouse_detector_resources_mouse_exited():
	mouseInResources = false

func _on_mouse_detector_output_mouse_entered():
	mouseInOutput = true

func _on_mouse_detector_output_mouse_exited():
	mouseInOutput = false

func _relitive(list, index, shift):
	var ret
	
	if typeof(list[0]) == 28:
		ret = []
		
		for item in list[0]:
			ret.append(null)
		
	else:
		ret = null
	
	if index + shift > -1 and index + shift < list.size():
		return list[index + shift]
		
	else:
		return ret
