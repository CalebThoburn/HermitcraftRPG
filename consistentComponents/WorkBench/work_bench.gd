extends Sprite2D

const TID_BIT_RESOURCE = preload("res://consistentComponents/WorkBench/tid_bit_resource.tscn")
const RESOURCE_PER_ROW = 3
const RESOURCE_SPACING = 9.0

const CRAFTING_CELL = preload("res://consistentComponents/WorkBench/crafting_cell.tscn")
const CELL_OFFSET = Vector2(35.84, 0)
const CELL_SPACING = 9.0
const CELL_GRID_SIZE = Vector2i(4, 4)

var currentBlueprint = {} # the current blueprint based upon the tidBits in the grid

func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("toggleCraft") and Global.playerAction >= Global.Actions.NULL:
		
		if visible:
			_close()
		
		else: 
			_open()

func _open():
	
	# create a resource for each tid bit type the player has at least one of
	_create_resource_bank()
	
	# creates empty crafting cells at the righ locations
	_create_empty_crafting_cells()
	
	Global.playerAction = Global.Actions.CRAFTING
	show()

func _create_resource_bank():
	
	var resourceIndex = 0 # keep track of unique resources in bank to know coords for resource
	var tidbitFrame = 0 # keep track of skipped TBs so we know how many frame to skip over
	
	for TB in Global.PLAYER.tidbits:
		
		var TBAmount = Global.PLAYER.tidbits[TB]
		
		if TBAmount > 0:
			var TBResource = TID_BIT_RESOURCE.instantiate()
			var TBResourcePosCoords = Vector2i(0, 0)
			TBResourcePosCoords.y = floor(resourceIndex / RESOURCE_PER_ROW)
			TBResourcePosCoords.x = resourceIndex - TBResourcePosCoords.y * RESOURCE_PER_ROW
			TBResource.position = TBResourcePosCoords * RESOURCE_SPACING
			TBResource.frame = Global.tidbitsFirstFrame[TB]
			TBResource.tidbit = TB
			add_child(TBResource)
			resourceIndex += 1

func _create_empty_crafting_cells():
	
	for x in range(CELL_GRID_SIZE.x):
		
		for y in range(CELL_GRID_SIZE.y):
			var cell = CRAFTING_CELL.instantiate()
			cell.coords = Vector2i(x, y)
			cell.position = cell.coords * CELL_SPACING + CELL_OFFSET
			add_child(cell)

func _close():
	Global.playerAction = Global.Actions.NULL
	hide()
