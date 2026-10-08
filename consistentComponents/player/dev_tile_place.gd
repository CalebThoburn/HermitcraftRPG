extends Sprite2D

func _ready() -> void:
	Global.devTile = Global.blockInfo.keys()[0]

func _process(_delta: float) -> void:
	
	# set frame to the current block selected, also update texture for changes being made
	texture = Global.blockSetTexture
	hframes = Global.BLOCKS_IN_ROW
	vframes = ceil(float(Global.blockInfo.size()) / float(Global.BLOCKS_IN_ROW))
	frame = Global.blockInfo.keys().find(Global.devTile)
	
	# if playerAction isn't place
	if Global.playerAction != Global.Actions.PLACE:
		hide()
	
	else:
		# if playerAction is place
		show()
		
		# place block on click
		if Input.is_action_pressed("click"):
			_place_block_by_ID(Global.blockInfo.keys().find(Global.devTile))
		
		# place air on rc
		if Input.is_action_pressed("rclick"):
			_place_block_by_ID(-1)
		
	# move to mouse
	position = floor((get_parent().get_local_mouse_position()) / Vector2(Global.TILE_PIXEL_SIZE)) * Vector2(Global.TILE_PIXEL_SIZE) + Vector2(Global.TILE_PIXEL_SIZE) / 2

func _place_block_by_ID(blockID):
	Global.TILE_MAP.place_block_by_ID(blockID, position / Vector2(Global.TILE_PIXEL_SIZE) + Vector2(-.5, -.5))
