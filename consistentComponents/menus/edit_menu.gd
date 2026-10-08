extends ColorRect

const colCornOffset = Vector2(26, 35)
const colCornFactor = 6.0 / 19.0

# the dragable collision corners for the block edit, starting w/ upper left and going clockwise
@export var colCornA: Node2D
@export var colCornB: Node2D
@export var colCornC: Node2D
@export var colCornD: Node2D

enum EditMode {
	RETEXTURE,
	COLLISION,
	CODE
}
var mode = EditMode.RETEXTURE # determins the features displayed on the edit menu
var tile # the tile being edited
var tileInfo = {}

# begins editing a tile (t)
func _open_edit(t):
	
	# set text field
	tile = t
	$TextEdit.text = tile
	
	# set fields if this isn't a new tile
	if t != "New Tile":
		tileInfo = Global.blockInfo[tile]
		Global.playerAction = Global.Actions.EDIT
		$Durability.text = str(tileInfo["durability"])
		
		# set collision
		if tileInfo["collision"] == PackedVector2Array([]):
			$CollisionMode/Collision.frame = 1
			$CollisionMode.collision = false
		
		else:
			$CollisionMode/Collision.frame = 0
			$CollisionMode.collision = true
			
			colCornA.position = (tileInfo["collision"][0] / colCornFactor) + colCornOffset
			colCornB.position = (tileInfo["collision"][1] / colCornFactor) + colCornOffset
			colCornC.position = (tileInfo["collision"][2] / colCornFactor) + colCornOffset
			colCornD.position = (tileInfo["collision"][3] / colCornFactor) + colCornOffset
		
		# set code
		if tileInfo.keys().has("code"):
			$CodeEdit.text = "\n".join(tileInfo["code"])
		
		else:
			$CodeEdit.text = ""
	
	$TextureEdit._draw_tile(tile)
	
	show()

# closes edit menu
func _close_edit():
	Global.playerAction = Global.Actions.PICK
	
	for child in $TextureEdit.get_children():
		child.queue_free()
	
	hide()

# switches from one edit mode to another
func _switch_edit_mode(newMode):
	
	match mode:
		
		EditMode.RETEXTURE:
			$ColorPicker.hide()
		
		EditMode.COLLISION:
			colCornA.hide()
			colCornB.hide()
			colCornC.hide()
			colCornD.hide()
			
		EditMode.CODE:
			$CodeEdit.hide()
	
	mode = newMode
	
	match mode:
		
		EditMode.RETEXTURE:
			$ColorPicker.show()
		
		EditMode.COLLISION:
			colCornA.show()
			colCornB.show()
			colCornC.show()
			colCornD.show()
		
		EditMode.CODE:
			$CodeEdit.show()

# serialize the data changed on the tile through the various children nodes save functions
func _save_tile():
	# set durability
	tileInfo["durability"] = float($Durability.text)
	
	# make sure name is valid
	if $TextEdit.text == "New Tile":
		pass
	
	## fix this!!!!!!!! yello? TOBEFIXED
	elif $TextEdit.text == "an already taken name. Caleb, fix this at some point":
		pass
	
	else:
		# save the texture
		$TextureEdit._save_tile()
		
		# save collision
		if $CollisionMode.collision:
			tileInfo["collision"] = PackedVector2Array([
				(colCornA.position - colCornOffset) * colCornFactor,
				(colCornB.position - colCornOffset) * colCornFactor,
				(colCornC.position - colCornOffset) * colCornFactor,
				(colCornD.position - colCornOffset) * colCornFactor
			])
		
		else:
			tileInfo["collision"] = PackedVector2Array([])
		
		# save code
		if $CodeEdit.text.length() > 0:
			tileInfo["code"] = $CodeEdit.text.split("\n", true)
		
		elif tileInfo.keys().has("code"):
			tileInfo.erase("code")
		
		## this is confusing, fix whatever is going on here
		if tile != "New Tile":
			# save the name by adding all values from dict to new dict, but changing the one we need too
			var newBlockInfo = {}
			
			for key in Global.blockInfo.keys():
				
				var info = Global.blockInfo[key]
				
				if key == tile:
					newBlockInfo[$TextEdit.text] = info
				
				else:
					newBlockInfo[key] = info
			
			Global.blockInfo = newBlockInfo
		
		# update the tileMap
		var imgTex = ImageTexture.create_from_image($TextureEdit.spriteSheetImg)
		Global.blockSetTexture = imgTex
		Global.TILE_MAP._load_tileset()
		
		# update tile menus
		Global.DEV_COMPS.get_node("TileMenus")._close_tile_dev()
		Global.DEV_COMPS.get_node("TileMenus")._open_tile_dev()
		
		# update blockInfo
		Global.blockInfo[$TextEdit.text] = tileInfo

func _on_close_button_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	
	if event.is_action_pressed("click"):
		_close_edit()
