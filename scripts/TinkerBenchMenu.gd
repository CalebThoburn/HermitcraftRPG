extends Sprite2D

const ACTION_SELECT = preload("res://scenes/lever_action_select.tscn")
const WIRE = preload("res://scenes/wire.tscn")
const ITEM = preload("res://scenes/collected_item.tscn")
const RESOURCE = preload("res://scenes/tinker_resource.tscn")
const INITIAL_X = -9
const INITIAL_Y = -13
const SPACING = 9
const OUTPUT_POS = Vector2(37, 14)
const WIRE_OFFSET = {"tip": Vector2(-5, 1), "funnel": Vector2(0, -4), "b": Vector2(0, 6), "t": Vector2(0, -3), "l": Vector2(-5, 1), "r": Vector2(4, 1)}

var output
var mouseInOutput = false
var mouseInGrid = false
var mouseInResources = false
var mouseItem = null
var resources = [
	[null, null], 
	[null, null],
	[null, null],
	[null, null]]
var grid = [
	[null, null, null, null], 
	[null, null, null, null], 
	[null, null, null, null], 
	[null, null, null, null]]
var blueprint = [
	[null, null, null, null], 
	[null, null, null, null], 
	[null, null, null, null], 
	[null, null, null, null]]
var anchors = [
	["b", "b", "b", "b"],
	["b", "b", "b", "b"],
	["b", "b", "b", "b"],
	["b", "b", "b", "b"]]
var connectionsFrom = [
	[null, null, null, null], 
	[null, null, null, null], 
	[null, null, null, null], 
	[null, null, null, null]]
var connectionsTo = [
	[null, null, null, null], 
	[null, null, null, null], 
	[null, null, null, null], 
	[null, null, null, null]]
var unlockedItems = ["barrel", "shaft", "tip", "funnel", "handle", "glass", "lever"]
var wire = null
var mouseIn = false

func _process(delta):
	
	if mouseInGrid or mouseInOutput or mouseInResources:
		mouseIn = true
	
	else:
		mouseIn = false
	
	var mouseGridPos = round((get_local_mouse_position() - Vector2(INITIAL_X, INITIAL_Y)) / SPACING)
	
	if get_node("../../Player/HotBar").mouseItem == null:
		
		if Input.is_action_just_pressed("right_click") and mouseInGrid:
			
			if wire == null:
				
				if blueprint[mouseGridPos.x][mouseGridPos.y] == "lever" and connectionsFrom[mouseGridPos.x][mouseGridPos.y] == null:
					wire = WIRE.instantiate()
					wire.position = Vector2(0, 0)
					wire.origin = mouseGridPos * SPACING + Vector2(INITIAL_X, INITIAL_Y)
					wire.color = 0
					wire.position += WIRE_OFFSET[anchors[mouseGridPos.x][mouseGridPos.y]]
					wire.from = mouseGridPos
					connectionsFrom[wire.from.x][wire.from.y] = wire
					add_child(wire)
			
			else:
				
				match blueprint[mouseGridPos.x][mouseGridPos.y]:
					
					"tip":
						connectionsTo[mouseGridPos.x][mouseGridPos.y] = wire
						wire.to = mouseGridPos
						wire.attached = true
						wire.end = mouseGridPos * SPACING + WIRE_OFFSET["tip"] + Vector2(INITIAL_X, INITIAL_Y) - WIRE_OFFSET[anchors[wire.from.x][wire.from.y]]
						wire = null
						output._update_invention()
					
					"funnel":
						connectionsTo[mouseGridPos.x][mouseGridPos.y] = wire
						wire.to = mouseGridPos
						wire.attached = true
						wire.end = mouseGridPos * SPACING + WIRE_OFFSET["funnel"] + Vector2(INITIAL_X, INITIAL_Y) - WIRE_OFFSET[anchors[wire.from.x][wire.from.y]]
						wire = null
						output._update_invention()
						
					_:
						wire.queue_free()
						wire = null
		
		if Input.is_action_just_pressed("click") and mouseInResources:
			
			if mouseItem != null:
				mouseItem.queue_free()
			
			if resources[mouseGridPos.y][-(mouseGridPos.x + 2)] != null:
				mouseItem = RESOURCE.instantiate()
				mouseItem.row = -1
				mouseItem.index = 0
				mouseItem.bit = resources[mouseGridPos.y][-(mouseGridPos.x + 2)].bit
				add_child(mouseItem)
		
		if Input.is_action_just_pressed("click") and mouseInGrid:
			var transferingItem = mouseItem
			blueprint[mouseGridPos.x][mouseGridPos.y] = null
			
			if mouseItem != null:
				transferingItem.row = mouseGridPos.x
				transferingItem.index = mouseGridPos.y
				blueprint[mouseGridPos.x][mouseGridPos.y] = transferingItem.bit
				
				if transferingItem.bit == "lever":
					
					if _relitive(blueprint[mouseGridPos.x], mouseGridPos.y, 1) != null:
						anchors[mouseGridPos.x][mouseGridPos.y] = "b"
						transferingItem.anchor = "b"
						
					elif _relitive(blueprint, mouseGridPos.x, 1)[mouseGridPos.y] != null:
						anchors[mouseGridPos.x][mouseGridPos.y] = "r"
						transferingItem.anchor = "r"
						
					elif _relitive(blueprint, mouseGridPos.x, -1)[mouseGridPos.y] != null:
						anchors[mouseGridPos.x][mouseGridPos.y] = "l"
						transferingItem.anchor = "l"
						
					elif _relitive(blueprint[mouseGridPos.x], mouseGridPos.y, -1) != null:
						anchors[mouseGridPos.x][mouseGridPos.y] = "t"
						transferingItem.anchor = "t"
					
					else:
						anchors[mouseGridPos.x][mouseGridPos.y] = "b"
						transferingItem.anchor = "b"
					
					transferingItem._update_bit()
					
					if transferingItem.action == 0:
						var actionSelect = ACTION_SELECT.instantiate()
						transferingItem.add_child(actionSelect)
			
			mouseItem = grid[mouseGridPos.x][mouseGridPos.y]
			
			if grid[mouseGridPos.x][mouseGridPos.y] != null:
				mouseItem.row = -1
				
				if connectionsTo[mouseGridPos.x][mouseGridPos.y] != null:
					connectionsTo[mouseGridPos.x][mouseGridPos.y].queue_free()
					connectionsTo[mouseGridPos.x][mouseGridPos.y] = null
				
				elif connectionsFrom[mouseGridPos.x][mouseGridPos.y] != null:
					connectionsFrom[mouseGridPos.x][mouseGridPos.y].queue_free()
					connectionsFrom[mouseGridPos.x][mouseGridPos.y] = null
				
				if mouseItem.action == 0 and mouseItem.bit == "lever":
					mouseItem.get_node("LeverActionSelect").queue_free()
			
			grid[mouseGridPos.x][mouseGridPos.y] = transferingItem
			output._update_invention()
		
		if Input.is_action_just_pressed("click") and mouseInOutput and _check_valid(blueprint):
			
			for bitRow in range(grid.size()):
				
				for bitIndex in range(grid[bitRow].size()):
					
					if grid[bitRow][bitIndex] != null:
						output.items[bitRow][bitIndex] = grid[bitRow][bitIndex].item
						
			
			get_node("../../Player/HotBar").mouseItem = output
			output.reparent(get_node("../../Player/HotBar"))
			_reset_board()
			_set_resources()
		
	elif mouseInGrid and Input.is_action_just_pressed("click") and get_node("../../Player/HotBar").mouseItem.item == "invention":
		
		_reset_board()
		_set_resources()
		
		var inv = get_node("../../Player/HotBar").mouseItem
		blueprint = inv.blueprint
		
		for row in range(blueprint.size()):
			
			for index in range(blueprint[row].size()):
				
				if blueprint[row][index] != null:
					var resource = RESOURCE.instantiate()
					grid[row][index] = resource
					resource.row = row
					resource.index = index
					resource.bit = blueprint[row][index]
					
					match resource.bit:
						
						"lever":
							
							resource.anchor = inv.anchors[row][index]
							anchors[row][index] = resource.anchor
							resource.action = inv.activations
							
							for connection in inv.activations:
								
								if connection[2] == Vector2(row, index):
									resource.action = connection[0]
									var wire = WIRE.instantiate()
									wire.position = Vector2(0, 0)
									wire.from = connection[2]
									wire.to = connection[1]
									wire.end = connection[1] * SPACING + WIRE_OFFSET[blueprint[connection[1].x][connection[1].y]] + Vector2(INITIAL_X, INITIAL_Y) - WIRE_OFFSET[anchors[wire.from.x][wire.from.y]]
									wire.origin = connection[2] * SPACING + Vector2(INITIAL_X, INITIAL_Y)
									wire.color = 0
									wire.position += WIRE_OFFSET[anchors[connection[2].x][connection[2].y]]
									connectionsFrom[wire.from.x][wire.from.y] = wire
									connectionsTo[wire.to.x][wire.to.y] = wire
									wire.attached = true
									add_child(wire)
						
						"barrel":
							resource.item = inv.items[row][index]
					
					add_child(resource)
					inv.queue_free()
					get_node("../../Player/HotBar").mouseItem = null
					output._update_invention()
					
	elif mouseInGrid and Input.is_action_just_pressed("click") and blueprint[mouseGridPos.x][mouseGridPos.y] == "barrel":
		
		var transitioningItem = grid[mouseGridPos.x][mouseGridPos.y].item
		
		grid[mouseGridPos.x][mouseGridPos.y].item = [get_node("../../Player/HotBar").mouseItem.item, get_node("../../Player/HotBar").mouseItem.count]
		get_node("../../Player/HotBar").mouseItem.item = transitioningItem[0]
		get_node("../../Player/HotBar").mouseItem.count = transitioningItem[1]
		get_node("../../Player/HotBar").mouseItem.get_node("ItemSprite").frame = get_node("../../Player/HotBar").mouseItem.ITEMS.find(get_node("../../Player/HotBar").mouseItem.item)
		
	if Input.is_action_just_pressed("left") or Input.is_action_just_pressed("right"):
		_close()

func _check_valid(blueprint):
	
	if blueprint == [[null, null, null, null], [null, null, null, null], [null, null, null, null], [null, null, null, null]]:
		return false
		
	else:
		return true

func _close():
	get_node("../../Player").crafting = false
	hide()
	_reset_board()

func _open():
	get_node("../../Player").crafting = true
	show()
	_reset_board()
	_set_resources()

func _set_resources():
	
	for bit in unlockedItems:
		var resource = RESOURCE.instantiate()
		resource.row = -2 - floor(unlockedItems.find(bit) / 4)
		resource.index = unlockedItems.find(bit) - floor(unlockedItems.find(bit) / 4) * 4
		resource.bit = bit
		resources[resource.index][floor(unlockedItems.find(bit) / 4)] = resource
		add_child(resource)

func _reset_board():
	
	grid = [
		[null, null, null, null], 
		[null, null, null, null], 
		[null, null, null, null], 
		[null, null, null, null]]
	blueprint = [
		[null, null, null, null], 
		[null, null, null, null], 
		[null, null, null, null], 
		[null, null, null, null]]
	anchors = [
		["b", "b", "b", "b"],
		["b", "b", "b", "b"],
		["b", "b", "b", "b"],
		["b", "b", "b", "b"]]
	connectionsFrom = [
		[null, null, null, null], 
		[null, null, null, null], 
		[null, null, null, null], 
		[null, null, null, null]]
	connectionsTo = [
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
