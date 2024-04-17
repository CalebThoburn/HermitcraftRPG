extends Node2D

const TID_BIT = preload("res://scenes/sprite_tid_bit.tscn")
const NUMBER = preload("res://scenes/number.tscn")
const NUMBER_Y = 2
const INITIAL_NUMBER_X = 2
const NUMBER_SPACING = -3
const ITEMS = ["grass", "dirt", "sand", "gravel", "stone", "coal_ore", "iron_ore", "diamond_ore", "leaves", "log", "stripped_log", "plank", "crafting_table", "barrel", "post", "glass", "flint", "coal", "diamond", "apple", "sapling", "stone_sword", "iron_sword", "diamond_sword", "slab", "wool", "red_wool", "webs", "boom_beatle"]
const TID_BITS = ["barrel", "funnel", "glass", "air", "tip", "handle", "shaft_l", "shaft", "lever_r", "lever_b", "lever_t", "air", "lever_l"]
const TB_SPACING = 2
const TB_IX = -2.5
const TB_IY = -2.5

var row # -1 for mouse
var index
var count
var item
var blueprint
var anchors
var activations
var items = [
	[["air", 0], ["air", 0], ["air", 0], ["air", 0]], 
	[["air", 0], ["air", 0], ["air", 0], ["air", 0]], 
	[["air", 0], ["air", 0], ["air", 0], ["air", 0]], 
	[["air", 0], ["air", 0], ["air", 0], ["air", 0]]]
var touchingMouse = false

@onready var tileMap = get_node("../../../TileMap")

func _ready():
	$ItemSprite.frame = ITEMS.find(item)
	
	if item == "invention":
		$ItemSprite.queue_free()
		_update_invention()
	
	elif row != -1:
		count = tileMap.inventory[row][index][1]
		_update_count()
	
	if get_parent().name != "TinkerBenchMenu":
		position.y = row * get_parent().ITEM_Y_SPACING + get_parent().INITIAL_Y
		position.x = index * get_parent().ITEM_X_SPACING + get_parent().INITIAL_X

func _process(delta):
		
	if get_parent().name == "TinkerBenchMenu":
		_crafting_output()
	
	else:
		_inventory_stuff()

func _inventory_stuff():
	
	if item != "invention":
		
		if count == 0:
			
			queue_free()
		
		_update_count()
	
	if row == -1:
		z_index = 1
		position = get_parent().get_local_mouse_position()
	
	else:
		z_index = 0
		position.y = row * get_parent().ITEM_Y_SPACING + get_parent().INITIAL_Y
		position.x = index * get_parent().ITEM_X_SPACING + get_parent().INITIAL_X
		
		if item != "invention":
			count = tileMap.inventory[row][index][1]

func _crafting_output():
	position = get_parent().OUTPUT_POS

func _update_count():
	
	for child in get_children():
		
		if child.name != "ItemSprite":
			
			child.queue_free()
	
	for character_index in range(str(count).length()):
		var character = str(count).reverse()[character_index]
		var number = NUMBER.instantiate()
		number.frame = int(character)
		number.position = Vector2(INITIAL_NUMBER_X + NUMBER_SPACING * character_index, NUMBER_Y)
		add_child(number)

func _update_invention():
	
	if get_parent().name == "TinkerBenchMenu":
		blueprint = get_parent().blueprint
		anchors = get_parent().anchors
		activations = []
		
		for row in get_parent().connectionsFrom:
			
			for connection in row:
				
				if connection != null:
					
					activations.append([get_parent().grid[connection.from[0]][connection.from[1]].action, connection.to, connection.from])
	
	for child in $TidBits.get_children():
		child.queue_free()
	
	for tbRow in range(blueprint.size()):
		
		for tbIndex in range(blueprint[tbRow].size()):
			
			if blueprint[tbRow][tbIndex] != null:
				var tidBit = TID_BIT.instantiate()
				var bit = blueprint[tbRow][tbIndex]
				tidBit.position = Vector2(TB_IY + TB_SPACING * tbRow, TB_IX + TB_SPACING * tbIndex)
				
				if bit == "lever":
					tidBit.frame = TID_BITS.find(bit + "_" + anchors[tbRow][tbIndex])
				else:
					tidBit.frame = TID_BITS.find(bit)
				
				if bit == "shaft":
					
					if _relitive(blueprint, tbRow, -1)[tbIndex] != "shaft":
						tidBit.frame = TID_BITS.find(bit + "_l")
				
				$TidBits.add_child(tidBit)

func _on_mouse_detecter_mouse_entered():
	touchingMouse = true

func _on_mouse_detecter_mouse_exited():
	touchingMouse = false

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
