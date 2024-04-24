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
const WIRE_OFFSET = {"computer_in": Vector2(-4, 3), "computer_out": Vector2(3, 3), "wheel": Vector2(0, 1), "antenna_1": Vector2(-1, 6), "antenna_2": Vector2(-1, 6), "tip": Vector2(-5, 1), "funnel": Vector2(1, -2), "b": Vector2(0, 6), "t": Vector2(0, -3), "l": Vector2(-5, 1), "r": Vector2(4, 1)}
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
	[{"top": null, "bottom": null, "both": null}, {"top": null, "bottom": null, "both": null}, {"top": null, "bottom": null, "both": null}, {"top": null, "bottom": null, "both": null}], 
	[{"top": null, "bottom": null, "both": null}, {"top": null, "bottom": null, "both": null}, {"top": null, "bottom": null, "both": null}, {"top": null, "bottom": null, "both": null}],
	[{"top": null, "bottom": null, "both": null}, {"top": null, "bottom": null, "both": null}, {"top": null, "bottom": null, "both": null}, {"top": null, "bottom": null, "both": null}],
	[{"top": null, "bottom": null, "both": null}, {"top": null, "bottom": null, "both": null}, {"top": null, "bottom": null, "both": null}, {"top": null, "bottom": null, "both": null}]]
var unlockedItems = ["wheel", "tip", "computer_flip", "antenna_1", "handle", "funnel", "computer_xor", "antenna_2", "trigger", "barrel", "computer_and"]
var wire = null
var mouseIn = false
var selecting = false

@onready var camera = get_node("../../Player/Camera")

func _process(delta):
	
	if mouseInGrid or mouseInOutput or mouseInResources:
		mouseIn = true
	
	else:
		mouseIn = false
	
	var mouseGridPos = round((get_local_mouse_position() - Vector2(INITIAL_X, INITIAL_Y)) / SPACING)
	var topOrBottom = floor((get_local_mouse_position() - Vector2(INITIAL_X, INITIAL_Y)) / SPACING).y - mouseGridPos.y
	
	if topOrBottom < 0:
		topOrBottom = "bottom"
		
	else:
		topOrBottom = "top"
	
	if !selecting:
		
		if get_node("../../Player/HotBar").mouseItem == null:
			
			if Input.is_action_just_pressed("right_click") and mouseInGrid:
				
				if wire == null:
					
					if grid[mouseGridPos.x][mouseGridPos.y] != null and grid[mouseGridPos.x][mouseGridPos.y].info["bit"] == "trigger" and grid[mouseGridPos.x][mouseGridPos.y].info["connectedTo"] == null:
						wire = WIRE.instantiate()
						wire.position = WIRE_OFFSET[grid[mouseGridPos.x][mouseGridPos.y].info["anchor"]]
						wire.origin = mouseGridPos * SPACING + Vector2(INITIAL_X, INITIAL_Y)
						wire.color = randi_range(0, 2)
						wire.from = {"coords": mouseGridPos, "topOrBottom": "both"}
						add_child(wire)
					
					elif grid[mouseGridPos.x][mouseGridPos.y] != null and grid[mouseGridPos.x][mouseGridPos.y].info["bit"].left(7) == "antenna" and grid[mouseGridPos.x][mouseGridPos.y].info["connectedTo"] == null:
						wire = WIRE.instantiate()
						wire.position = WIRE_OFFSET[grid[mouseGridPos.x][mouseGridPos.y].info["bit"]]
						wire.color = randi_range(0, 2)
						wire.origin = mouseGridPos * SPACING + Vector2(INITIAL_X, INITIAL_Y)
						wire.from = {"coords": mouseGridPos, "topOrBottom": "both"}
						add_child(wire)
					
					elif grid[mouseGridPos.x][mouseGridPos.y] != null and grid[mouseGridPos.x][mouseGridPos.y].info["bit"].left(8) == "computer" and grid[mouseGridPos.x][mouseGridPos.y].info["connectedTo"][topOrBottom] == null:
						wire = WIRE.instantiate()
						wire.position = WIRE_OFFSET["computer_out"]
						wire.origin = mouseGridPos * SPACING + Vector2(INITIAL_X, INITIAL_Y)
						wire.color = randi_range(0, 2)
						
						if topOrBottom == "bottom":
							wire.position.y -= 3
						
						wire.from = {"coords": mouseGridPos, "topOrBottom": topOrBottom}
						add_child(wire)
					
				elif wiresByEnd[mouseGridPos.x][mouseGridPos.y]["top"] == null and grid[mouseGridPos.x][mouseGridPos.y] != null and WIRE_ENDS.has(grid[mouseGridPos.x][mouseGridPos.y].info["bit"]):
					
					if grid[mouseGridPos.x][mouseGridPos.y].info["bit"].left(8) != "computer":
						topOrBottom = "both"
					
					if grid[wire.from["coords"].x][wire.from["coords"].y].info["bit"].left(8) == "computer":
						grid[wire.from["coords"].x][wire.from["coords"].y].info["connectedTo"][wire.from["topOrBottom"]] = {"coords": mouseGridPos, "topOrBottom": topOrBottom}
						wire.to = grid[wire.from["coords"].x][wire.from["coords"].y].info["connectedTo"][wire.from["topOrBottom"]]
						wiresByEnd[wire.to["coords"].x][wire.to["coords"].y][topOrBottom] = wire
						
						
					else:
						grid[wire.from["coords"].x][wire.from["coords"].y].info["connectedTo"] = {"coords": mouseGridPos, "topOrBottom": "both"}
						wire.to = grid[wire.from["coords"].x][wire.from["coords"].y].info["connectedTo"]
						wiresByEnd[wire.to["coords"].x][wire.to["coords"].y]["top"] = wire
						wiresByEnd[wire.to["coords"].x][wire.to["coords"].y]["bottom"] = wire
					
					wire.attached = true
					wire.end = mouseGridPos * SPACING + WIRE_OFFSET[grid[mouseGridPos.x][mouseGridPos.y].info["bit"]] + Vector2(INITIAL_X, INITIAL_Y)
					
					if grid[wire.from["coords"].x][wire.from["coords"].y].info["bit"] == "trigger":
						wire.end -= WIRE_OFFSET[grid[wire.from["coords"].x][wire.from["coords"].y].info["anchor"]]
						
					elif grid[wire.from["coords"].x][wire.from["coords"].y].info["bit"].left(8) == "computer":
						wire.end -= WIRE_OFFSET["computer_out"]
						
						if wire.from["topOrBottom"] == "bottom":
							wire.end.y += 3
						
					else:
						wire.end -= WIRE_OFFSET[grid[wire.from["coords"].x][wire.from["coords"].y].info["bit"]]
					
					wire = null
					output._update_invention()
					
				elif grid[mouseGridPos.x][mouseGridPos.y] != null and grid[mouseGridPos.x][mouseGridPos.y].info["bit"].left(8) == "computer" and wiresByEnd[mouseGridPos.x][mouseGridPos.y][topOrBottom] == null:
					
					if wire.from["topOrBottom"] == "both":
						grid[wire.from["coords"].x][wire.from["coords"].y].info["connectedTo"] = {"coords": mouseGridPos, "topOrBottom": topOrBottom}
						
					else:
						grid[wire.from["coords"].x][wire.from["coords"].y].info["connectedTo"][wire.from["topOrBottom"]] = {"coords": mouseGridPos, "topOrBottom": topOrBottom}
					
					wire.to = {"coords": mouseGridPos, "topOrBottom": topOrBottom}
					wire.attached = true
					
					if topOrBottom == "top":
						wire.end = mouseGridPos * SPACING + WIRE_OFFSET["computer_in"] + Vector2(INITIAL_X, INITIAL_Y)
					
					else:
						wire.end = mouseGridPos * SPACING + WIRE_OFFSET["computer_in"] + Vector2(INITIAL_X, INITIAL_Y - 3)
					
					if grid[wire.from["coords"].x][wire.from["coords"].y].info["bit"] == "trigger":
						wire.end -= WIRE_OFFSET[grid[wire.from["coords"].x][wire.from["coords"].y].info["anchor"]]
						
					elif grid[wire.from["coords"].x][wire.from["coords"].y].info["bit"].left(8) == "computer":
						wire.end -= WIRE_OFFSET["computer_out"]
						
						if wire.from["topOrBottom"] == "bottom":
							wire.end.y += 3
						
					else:
						wire.end -= WIRE_OFFSET[grid[wire.from["coords"].x][wire.from["coords"].y].info["bit"]]
					
					wiresByEnd[wire.to["coords"].x][wire.to["coords"].y][wire.to["topOrBottom"]] = wire
					wire = null
					output._update_invention()
				
				else:
					wire.queue_free()
					wire = null
			
			if Input.is_action_just_pressed("click") and mouseInResources and wire == null:
				
				if mouseItem != null:
					mouseItem.queue_free()
				
				elif resources[mouseGridPos.y][-(mouseGridPos.x + 2)] != null:
					mouseItem = RESOURCE.instantiate()
					mouseItem.row = -1
					mouseItem.index = 0
					mouseItem.info["bit"] = resources[mouseGridPos.y][-(mouseGridPos.x + 2)].info["bit"]
					_set_defaults(mouseItem)
					add_child(mouseItem)
			
			if Input.is_action_just_pressed("click") and mouseInGrid and wire == null:
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
					
					if mouseItem.info["connectedTo"] != null and mouseItem.info["connectedTo"] != {"top": null, "bottom": null}:
						
						if mouseItem.info["bit"].left(8) == "computer":
							
							if mouseItem.info["connectedTo"]["top"] != null:
								
								if mouseItem.info["connectedTo"]["top"]["topOrBottom"] == "both":
									wiresByEnd[mouseItem.info["connectedTo"]["top"]["coords"].x][mouseItem.info["connectedTo"]["top"]["coords"].y]["both"].queue_free()
									wiresByEnd[mouseItem.info["connectedTo"]["top"]["coords"].x][mouseItem.info["connectedTo"]["top"]["coords"].y] = {"top": null, "bottom": null, "both": null}
								
								else:
									wiresByEnd[mouseItem.info["connectedTo"]["top"]["coords"].x][mouseItem.info["connectedTo"]["top"]["coords"].y][mouseItem.info["connectedTo"]["top"]["topOrBottom"]].queue_free()
									wiresByEnd[mouseItem.info["connectedTo"]["top"]["coords"].x][mouseItem.info["connectedTo"]["top"]["coords"].y][mouseItem.info["connectedTo"]["top"]["topOrBottom"]] = null
							
							if mouseItem.info["connectedTo"]["bottom"] != null:
								
								if mouseItem.info["connectedTo"]["bottom"]["topOrBottom"] == "both":
									wiresByEnd[mouseItem.info["connectedTo"]["bottom"]["coords"].x][mouseItem.info["connectedTo"]["bottom"]["coords"].y]["both"].queue_free()
									wiresByEnd[mouseItem.info["connectedTo"]["bottom"]["coords"].x][mouseItem.info["connectedTo"]["bottom"]["coords"].y] = {"top": null, "bottom": null, "both": null}
								
								else:
									wiresByEnd[mouseItem.info["connectedTo"]["bottom"]["coords"].x][mouseItem.info["connectedTo"]["bottom"]["coords"].y][mouseItem.info["connectedTo"]["bottom"]["topOrBottom"]].queue_free()
									wiresByEnd[mouseItem.info["connectedTo"]["bottom"]["coords"].x][mouseItem.info["connectedTo"]["bottom"]["coords"].y][mouseItem.info["connectedTo"]["bottom"]["topOrBottom"]] = null
							
							mouseItem.info["connectedTo"] = {"top": null, "bottom": null}
							
						else:
							
							if mouseItem.info["connectedTo"]["topOrBottom"] == "both":
								wiresByEnd[mouseItem.info["connectedTo"]["coords"].x][mouseItem.info["connectedTo"]["coords"].y]["top"].queue_free()
								wiresByEnd[mouseItem.info["connectedTo"]["coords"].x][mouseItem.info["connectedTo"]["coords"].y] = {"top": null, "bottom": null, "both": null}
							
							else:
								wiresByEnd[mouseItem.info["connectedTo"]["coords"].x][mouseItem.info["connectedTo"]["coords"].y][mouseItem.info["connectedTo"]["topOrBottom"]].queue_free()
								wiresByEnd[mouseItem.info["connectedTo"]["coords"].x][mouseItem.info["connectedTo"]["coords"].y][mouseItem.info["connectedTo"]["topOrBottom"]] = null
							
							mouseItem.info["connectedTo"] = null
					
					if wiresByEnd[mouseGridPos.x][mouseGridPos.y] != {"top": null, "bottom": null, "both": null}:
						
						if wiresByEnd[mouseGridPos.x][mouseGridPos.y]["top"] == null and wiresByEnd[mouseGridPos.x][mouseGridPos.y]["bottom"] == null:
							var deadWire = wiresByEnd[mouseGridPos.x][mouseGridPos.y]["both"]
							
							if deadWire.from["topOrBottom"] == "both":
								wiresByEnd[mouseGridPos.x][mouseGridPos.y]["both"] = null
								grid[deadWire.from["coords"].x][deadWire.from["coords"].y].info["connectedTo"] = null
								
							else:
								grid[deadWire.from["coords"].x][deadWire.from["coords"].y].info["connectedTo"][deadWire.from["topOrBottom"]] = null
								wiresByEnd[mouseGridPos.x][mouseGridPos.y]["both"] = null
								
							deadWire.queue_free()
						
						else:
						
							if wiresByEnd[mouseGridPos.x][mouseGridPos.y]["top"] != null:
								var deadWire = wiresByEnd[mouseGridPos.x][mouseGridPos.y]["top"]
								
								if deadWire.from["topOrBottom"] == "both":
									wiresByEnd[mouseGridPos.x][mouseGridPos.y]["top"] = null
									grid[deadWire.from["coords"].x][deadWire.from["coords"].y].info["connectedTo"] = null
									
								else:
									grid[deadWire.from["coords"].x][deadWire.from["coords"].y].info["connectedTo"][deadWire.from["topOrBottom"]] = null
									wiresByEnd[mouseGridPos.x][mouseGridPos.y]["top"] = null
									
								deadWire.queue_free()
							
							if wiresByEnd[mouseGridPos.x][mouseGridPos.y]["bottom"] != null:
								var deadWire = wiresByEnd[mouseGridPos.x][mouseGridPos.y]["bottom"]
								
								if deadWire.from["topOrBottom"] == "both":
									wiresByEnd[mouseGridPos.x][mouseGridPos.y]["bottom"] = null
									grid[deadWire.from["coords"].x][deadWire.from["coords"].y].info["connectedTo"] = null
									
								else:
									grid[deadWire.from["coords"].x][deadWire.from["coords"].y].info["connectedTo"]["bottom"] = null
									wiresByEnd[mouseGridPos.x][mouseGridPos.y]["bottom"] = null
									
								deadWire.queue_free()
							
					if mouseItem.info["bit"] == "trigger" and  mouseItem.info["action"] == 0:
						mouseItem.get_node("LeverActionSelect").queue_free()
					
					elif mouseItem.info["bit"] == "funnel" and mouseItem.info["anchor"] == null:
						mouseItem.get_node("FunnelDirectionSelect").queue_free()
				
				grid[mouseGridPos.x][mouseGridPos.y] = transferingItem
				output._update_invention()
			
			if Input.is_action_just_pressed("click") and mouseInOutput and _type(grid) != "invaild" and wire == null:
				
				for rowIndex in range(grid.size()):
					
					for bitIndex in range(grid[rowIndex].size()):
						
						if grid[rowIndex][bitIndex] != null:
							output.blueprint[rowIndex][bitIndex] = grid[rowIndex][bitIndex].info
				
				get_node("../../Player/HotBar").mouseItem = output
				output.reparent(get_node("../../Player/HotBar"))
				output.item = _type(grid)
				_reset_board()
				_set_resources()
			
		elif wire == null and mouseInGrid and Input.is_action_just_pressed("click") and get_node("../../Player/HotBar").mouseItem.item == "invention":
			
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
							wire.end = wire.to["coords"] * SPACING + WIRE_OFFSET[blueprint[wire.to["coords"].x][ wire.to["coords"].y]["bit"]] + Vector2(INITIAL_X, INITIAL_Y) - WIRE_OFFSET[resource.info["anchor"]]
							wire.origin = wire.from * SPACING + Vector2(INITIAL_X, INITIAL_Y)
							wire.attached = true
							wire.color = randi_range(0, 2)
							
							if blueprint[wire.to["coords"].x][wire.to["coords"].y]["anchor"] == null:
								wire.position += WIRE_OFFSET[blueprint[wire.to["coords"].x][wire.to["coords"].y]["bit"]]
								
							else:
								wire.position += WIRE_OFFSET[blueprint[wire.to["coords"].x][wire.to["coords"].y]["anchor"]]
							wire.attached = true
							add_child(wire)
						
						add_child(resource)
				
			inv.queue_free()
			get_node("../../Player/HotBar").mouseItem = null
			output._update_invention()
						
		elif wire == null and mouseInGrid and Input.is_action_just_pressed("click") and grid[mouseGridPos.x][mouseGridPos.y] != null and grid[mouseGridPos.x][mouseGridPos.y].info["bit"] == "barrel":
			
			var info = grid[mouseGridPos.x][mouseGridPos.y].info.duplicate(true)
			
			grid[mouseGridPos.x][mouseGridPos.y].info["item"] = get_node("../../Player/HotBar").mouseItem.item
			grid[mouseGridPos.x][mouseGridPos.y].info["count"] = get_node("../../Player/HotBar").mouseItem.count
			get_node("../../Player/HotBar").mouseItem.item = info["item"]
			get_node("../../Player/HotBar").mouseItem.count = info["count"]
			get_node("../../Player/HotBar").mouseItem.get_node("ItemSprite").frame = get_node("../../Player/HotBar").mouseItem.ITEMS.find(get_node("../../Player/HotBar").mouseItem.item)
			
	if Input.is_action_just_pressed("left") or Input.is_action_just_pressed("right"):
		_close()

func _set_defaults(mouseItem):
	
	mouseItem.info.merge({"powered": {"both": false},"anchor": null, "connectedTo": null, "action": null, "item": "air", "count": 0, "direction": null, "flop": false})
	
	if mouseItem.info["bit"].left(8) == "computer":
		mouseItem.info["connectedTo"] = {"top": null, "bottom": null}
		mouseItem.info["powered"] = {"top": false, "bottom": false}
	
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
	camera.origin = camera.position
	camera.destination = Vector2(0, 0)
	camera.originZoom = camera.zoom
	camera.destinedZoom = Vector2(4, 4)
	camera.startTime = Time.get_ticks_msec() / 1000.0
	hide()
	_reset_board()

func _open():
	selecting = false
	get_node("../../Player").crafting = true
	camera.origin = camera.position
	camera.destination = position - get_node("../../Player").position + Vector2(0, -10)
	camera.originZoom = camera.zoom
	camera.destinedZoom = Vector2(8, 8)
	camera.startTime = Time.get_ticks_msec() / 1000.0
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
		[{"top": null, "bottom": null, "both": null}, {"top": null, "bottom": null, "both": null}, {"top": null, "bottom": null, "both": null}, {"top": null, "bottom": null, "both": null}], 
		[{"top": null, "bottom": null, "both": null}, {"top": null, "bottom": null, "both": null}, {"top": null, "bottom": null, "both": null}, {"top": null, "bottom": null, "both": null}],
		[{"top": null, "bottom": null, "both": null}, {"top": null, "bottom": null, "both": null}, {"top": null, "bottom": null, "both": null}, {"top": null, "bottom": null, "both": null}],
		[{"top": null, "bottom": null, "both": null}, {"top": null, "bottom": null, "both": null}, {"top": null, "bottom": null, "both": null}, {"top": null, "bottom": null, "both": null}]]
	
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
