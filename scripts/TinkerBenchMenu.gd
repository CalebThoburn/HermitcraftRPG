extends Sprite2D

const ITEM = preload("res://scenes/collected_item.tscn")
const RESOURCE = preload("res://scenes/tinker_resource.tscn")
const INITIAL_X = -9
const INITIAL_Y = -13
const SPACING = 9
const OUTPUT_POS = Vector2(37, 14)

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
var unlockedItems = ["barrel", "shaft", "tip", "funnel", "handle", "glass", "lever_b"]

func _process(delta):
	
	var mouseGridPos = round((get_local_mouse_position() - Vector2(INITIAL_X, INITIAL_Y)) / 9)
	
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
		
		mouseItem = grid[mouseGridPos.x][mouseGridPos.y]
		
		if grid[mouseGridPos.x][mouseGridPos.y] != null:
			mouseItem.row = -1
		
		grid[mouseGridPos.x][mouseGridPos.y] = transferingItem
		output.blueprint = blueprint
		output._update_invention()
	
	if Input.is_action_just_pressed("click") and mouseInOutput and get_node("../../Player/HotBar").mouseItem == null:
		get_node("../../Player/HotBar").mouseItem = output
		output.reparent(get_node("../../Player/HotBar"))
		_reset_board()
	
	if Input.is_action_just_pressed("left") or Input.is_action_just_pressed("right"):
		_close()

func _close():
	get_node("../../Player").crafting = false
	hide()
	_reset_board()

func _open():
	get_node("../../Player").crafting = true
	show()
	
	_reset_board()
	
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
