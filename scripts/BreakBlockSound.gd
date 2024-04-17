extends AudioStreamPlayer2D

const COOLDWON = .3
const BLOCK_SOUNDS = {
	"grass": [
		preload("res://audio/blocks/grass/break/GrassBreak1.mp3"), 
		preload("res://audio/blocks/grass/break/GrassBreak2.mp3"), 
		preload("res://audio/blocks/grass/break/GrassBreak3.mp3"), 
		preload("res://audio/blocks/grass/break/GrassBreak4.mp3"), 
		preload("res://audio/blocks/grass/break/GrassBreak5.mp3"), 
		preload("res://audio/blocks/grass/break/GrassBreak6.mp3"), 
		preload("res://audio/blocks/grass/break/GrassBreak7.mp3"), 
		preload("res://audio/blocks/grass/break/GrassBreak8.mp3")]}

var targetAtlas = Vector2(0, 0)
var cooldown = 0

@onready var tileMap = get_node("../../TileMap")

func _process(delta):
	
	cooldown -= delta
	
	if cooldown < 0:
		cooldown = 0
	
	var block = tileMap.local_to_map(get_parent().position) - Vector2i(0, -2)
	var topLayer = 0
	for layer in range(tileMap.LAYERS):
		
		if tileMap.get_cell_tile_data(layer * -1 + tileMap.LAYERS - 1, block) != null:
			topLayer = layer * -1 + tileMap.LAYERS - 1
			break
			
	targetAtlas = tileMap.get_cell_atlas_coords(topLayer, block)
	
func _play():
	
	cooldown = COOLDWON
	
	if BLOCK_SOUNDS.keys().has(tileMap.BLOCK_FRAME[targetAtlas.x + targetAtlas.y * 8]):
		stream = BLOCK_SOUNDS[tileMap.BLOCK_FRAME[targetAtlas.x + targetAtlas.y * 8]].pick_random()
		play()

