extends Sprite2D

var tile: String

func _ready() -> void:
	
	$Label.text = tile
	
	if tile != "New Tile":
		$Tile.texture = Global.blockSetTexture
		$Tile.hframes = Global.BLOCKS_IN_ROW
		$Tile.vframes = ceil(float(Global.blockInfo.size()) / float(Global.BLOCKS_IN_ROW))
		$Tile.frame = Global.blockInfo.keys().find(tile)

# set dev_tile on select area clicked in menu, and if this isn't the "New Tile" menu
func _on_dev_tile_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	
	if event.is_action_pressed("click") and Global.playerAction == Global.Actions.PICK and tile != "New Tile":
		Global.devTile = tile

# show edit icon if hovering
func _on_tile_edit_mouse_entered() -> void:
	$EditIcon.show()

# hide edit icon if stopped hovering
func _on_tile_edit_mouse_exited() -> void:
	$EditIcon.hide()

# edit tile on edit area clicked and in menu
func _on_tile_edit_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	
	if event.is_action_pressed("click") and Global.playerAction == Global.Actions.PICK:
		Global.DEV_COMPS.get_node("EditMenu")._open_edit(tile)
