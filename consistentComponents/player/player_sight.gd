extends Sprite2D

const FRAMES = 9

var currentBlockPosition = Vector2(0, 0) # the position of the current block working towards being broken
var breakProgress = 0.0 # how long the mouse has been held

func _ready() -> void:
	# set texture from sprite in current mod file
	texture = load(Global.modFilePath + "/player/SightIndicator.png")

func _process(delta: float) -> void:
	
	# NULL is if the player is in 'survival' and not crafting or anything
	if Global.playerAction == Global.Actions.NULL:
		_player_sight_process(delta)
		show()
	
	else:
		breakProgress = 0.0
		hide()

func _player_sight_process(delta):
	# move to mouse
	position = floor((get_parent().get_local_mouse_position()) / Vector2(Global.TILE_PIXEL_SIZE)) * Vector2(Global.TILE_PIXEL_SIZE) + Vector2(Global.TILE_PIXEL_SIZE) / 2
	
	# advance break progress, reset it if click isn't held or if block changes
	if !Input.is_action_pressed("click") or position != currentBlockPosition:
		breakProgress = 0.0
	
	else:
		breakProgress += delta
	
	# set frame based on breakProgress and current block's durability
	var currentBlockVect2i = Global.TILE_MAP.local_to_map(currentBlockPosition)
	var currentBlockAtlasCoords = Global.TILE_MAP.get_cell_atlas_coords(currentBlockVect2i)
	
	# but only if AtlasCoords is an entry in blocksByAtlasCoords (i.e. not air)
	if Global.TILE_MAP.blocksByAtlasCoords.keys().has(currentBlockAtlasCoords):
		var currentBlock = Global.TILE_MAP.blocksByAtlasCoords[currentBlockAtlasCoords]
		var blockDur = Global.blockInfo[currentBlock]["durability"]
		frame = floor(breakProgress / blockDur * FRAMES)
		
		# break block if progress is greater than dur
		if breakProgress > blockDur:
			Global.TILE_MAP.place_block_by_ID(-1, currentBlockVect2i)
			frame = 0
		
	# make sure the current block being worked on is the one at this pos
	currentBlockPosition = position
