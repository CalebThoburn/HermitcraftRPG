extends ColorRect

const PIXEL = preload("res://consistentComponents/menus/texture_pixel.tscn")

var pixelToCoords: Dictionary # will be filled with pixelNodes as keys, with coords(in tile) for values
var changes: Array[Dictionary] = [] # list of changes for undoing and saving purposes
var tileCoords # the atlas coords of the tile

# gets the spritesheet as an img that can be read and written to, should be saved to file on game close/save
@onready var spriteSheetImg: Image = load(Global.modFilePath + "/blocks/blockset.png").get_image()

func _draw_tile(tile):
	
	# calculate how large to make each "pixel"
	var buffer = Vector2(1.0, 1.0)
	var pixelStep: Vector2 = (size - buffer * 2) / Vector2(Global.TILE_PIXEL_SIZE)
	
	# get texture as readable img 
	var blockID
	
	if get_parent().tile == "New Tile":
		blockID = Global.blockInfo.keys().size()
	
	else:
		blockID = Global.blockInfo.keys().find(tile)
	
	tileCoords = Vector2i(blockID - Global.BLOCKS_IN_ROW * floor(blockID/Global.BLOCKS_IN_ROW), floor(blockID/Global.BLOCKS_IN_ROW))
	
	# layout each pixel of texture, setting its color as we go
	for x in range(Global.TILE_PIXEL_SIZE.x):
		
		for y in range(Global.TILE_PIXEL_SIZE.y):
			var pixel = PIXEL.instantiate()
			pixel.modulate = spriteSheetImg.get_pixelv(tileCoords * Global.TILE_PIXEL_SIZE + Vector2i(x, y))
			pixel.scale = pixelStep
			pixel.position = Vector2(x, y) * pixelStep + buffer
			pixelToCoords[pixel] = Vector2(x, y)
			add_child(pixel)

func _process(delta: float) -> void:
	
	# only run processes and checks for edit if in EDIT mode and in editMode RETEXTURE
	if Global.playerAction == Global.Actions.EDIT and get_parent().mode == get_parent().EditMode.RETEXTURE:
		_edit_process(delta)

# process to be run every frame if in edit mode
func _edit_process(delta):
	
	if Input.is_action_just_pressed("undo") and changes.size() > 0:
		var lastChange = changes[-1]
		lastChange["pixel"].modulate = lastChange["oldColor"]
		changes.remove_at(-1)

# writes the current tile w/ changes to the spriteSheetImg, and then serializes the spriteSheet
func _save_tile():
	
	for change in changes:
		spriteSheetImg.set_pixelv(tileCoords * Global.TILE_PIXEL_SIZE + Vector2i(pixelToCoords[change["pixel"]]), change["newColor"])
	
	spriteSheetImg.save_png(Global.modFilePath + "/blocks/blockset.png")
	changes = []
