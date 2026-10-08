extends ScrollContainer

const TILE_MENU = preload("res://consistentComponents/menus/tile_menu.tscn")
const TILE_MENU_OFFSET_Y_INC = 13.5

func _ready() -> void:
	_open_tile_dev()

# lists the tiles in menus to be placed and edited as in dev mode
func _open_tile_dev():
	
	var tileIndex = 0
	
	for tile in Global.blockInfo.keys():
		
		var tileMenu = TILE_MENU.instantiate()
		tileMenu.position.y += TILE_MENU_OFFSET_Y_INC * tileIndex
		tileMenu.tile = tile
		$Container.add_child(tileMenu)
		$Container.custom_minimum_size.y += TILE_MENU_OFFSET_Y_INC
		
		tileIndex += 1
	
	# add an extra menu that can be used to make a new tile
	var newTile = TILE_MENU.instantiate()
	newTile.position.y += TILE_MENU_OFFSET_Y_INC * tileIndex
	newTile.tile = "New Tile"
	$Container.add_child(newTile)
	$Container.custom_minimum_size.y += TILE_MENU_OFFSET_Y_INC
	
	show()

# closes the dev menu
func _close_tile_dev():
	$Container.custom_minimum_size.y = 0
	
	for child in $Container.get_children():
		child.queue_free()
	
	hide()

func _on_mouse_entered() -> void:
	
	# if in placing mode, switch to pick mode when entered
	if Global.playerAction == Global.Actions.PLACE:
		Global.playerAction = Global.Actions.PICK

func _on_mouse_exited() -> void:
	
	# if in placing mode, switch to pick mode when entered
	if Global.playerAction == Global.Actions.PICK:
		Global.playerAction = Global.Actions.PLACE
