extends TileMapLayer

const CHUNK_LENGTH = 12 # side length of chunks
const BLOCK_BYTE_SIZE = 1 # the number bits used to define a bloc
const BYTES_IN_CHUNK: int = pow(CHUNK_LENGTH, 2) * BLOCK_BYTE_SIZE # how many bytes each chunk takes to store

var blocksByAtlasCoords = {} # atlas coords to block name
var chunkDict = {} # loaded chunks by their cords, to be saved
var chunkRef = [] # the order of chunks in the packedByteArray
var chunkMapFile # the file containing the map data

func _ready() -> void:
	Global.TILE_MAP = self
	
	_load_tileset()
	_load_chunk_data(Global.save)
	
	for chunk in chunkRef:
		load_chunk(chunk.x, chunk.y, true)

# places the blocks for a given chunk as stored in the system
func load_chunk(chunkX, chunkY, initialLoad):
	var chunk = _chunk_map(chunkX, chunkY)
	
	for x in range(CHUNK_LENGTH):
		
		for y in range(CHUNK_LENGTH):
			var blockID = chunk[y * CHUNK_LENGTH + x]
			place_block_by_ID(blockID, Vector2i(chunkX, chunkY) * CHUNK_LENGTH + Vector2i(x, y), !initialLoad)

## [code]locPos[/code]: The local x-y coord of the block, NOT using the grid coords
func place_block_by_ID(blockID, locPos, editSave: bool = true):
	var blockPos = Vector2i(locPos)
	
	# -1 for air
	if blockID == -1:
		blockID = BLOCK_BYTE_SIZE * 256 - 1
		erase_cell(blockPos)
	
	# positive blockId for actual blocks
	else:
		var atlasCoords = Vector2i(blockID - Global.BLOCKS_IN_ROW * floor(blockID/Global.BLOCKS_IN_ROW), floor(blockID/Global.BLOCKS_IN_ROW))
		
		set_cell(blockPos, Global.tileSetSourceId, atlasCoords)
	
	var chunk = Vector2i(floor(locPos / float(CHUNK_LENGTH)))
	var internalBlockPos = blockPos - chunk * CHUNK_LENGTH
	
	# if editSave is true, then queue chunk to be saved
	if editSave:
		
		if chunkDict.has(chunk):
			pass
		
		elif chunkRef.has(chunk):
			chunkDict[chunk] = _chunk_map(chunk.x, chunk.y)
		
		else:
			chunkRef.append(chunk)
			chunkDict[chunk] = _empty_chunk()
			
		chunkDict[chunk][internalBlockPos.x + internalBlockPos.y * CHUNK_LENGTH * BLOCK_BYTE_SIZE] = blockID

# loads the blocks from current mod/default as the world tileset
func _load_tileset():
	# load spritesheet
	
	if Global.tileSetSourceId != null:
		tile_set.remove_source(Global.tileSetSourceId)
		
	Global.tileSetSourceId = 9
	
	var blockTileSetSource = TileSetAtlasSource.new()
	
	blockTileSetSource.texture_region_size = Global.TILE_PIXEL_SIZE
	blockTileSetSource.texture = AtlasTexture.new()
	blockTileSetSource.texture.atlas = Global.blockSetTexture
	Global.tileSetSourceId = tile_set.add_source(blockTileSetSource, Global.tileSetSourceId)
	
	# iterate through each block
	var blockIndex = -1
	
	for block in Global.blockInfo.keys():
		blockIndex += 1
		var blockAtlasCoords = Vector2i(0, 0)
		blockAtlasCoords.y = floor(blockIndex / Global.BLOCKS_IN_ROW)
		blockAtlasCoords.x = blockIndex - blockAtlasCoords.y * Global.BLOCKS_IN_ROW
		
		# add collision to block
		var polygon = Global.blockInfo[block]["collision"]
		
		blockTileSetSource.create_tile(blockAtlasCoords, Vector2i(1, 1))
		var tileData = blockTileSetSource.get_tile_data(blockAtlasCoords, 0)
		tileData.set_collision_polygons_count(0, 1)
		tileData.set_collision_polygon_points(0, 0, polygon)
		
		# add block to dict indexing blocks by atlasCoords
		blocksByAtlasCoords[blockAtlasCoords] = block

# pulls the saved data from the files(which files depends on the saveFileName) into the variables, doesn't set blocks or anything visible.
func _load_chunk_data(saveFileName):
	var chunkRefFile = FileAccess.open("res://saves/" + saveFileName + "/chunkReference.txt", FileAccess.READ)
	chunkRef = chunkRefFile.get_var()
	chunkRefFile.close()
	
	chunkMapFile = FileAccess.open("res://saves/" + saveFileName + "/chunkBits.txt", FileAccess.READ)

# saves the map to the given file
func _save_map(saveFileName):
	# no more reading
	chunkMapFile.close()
	# time to write
	chunkMapFile = FileAccess.open("res://saves/" + saveFileName + "/chunkBits.txt", FileAccess.READ_WRITE)
	
	for chunk in chunkDict:
		chunkMapFile.seek(chunkRef.find(chunk) * BYTES_IN_CHUNK)
		chunkMapFile.store_buffer(chunkDict[chunk])
	
	chunkMapFile.close()
	
	# save the order of chunks
	var chunkRefFile = FileAccess.open("res://saves/" + saveFileName + "/chunkReference.txt", FileAccess.WRITE)
	chunkRefFile.store_var(chunkRef)
	chunkRefFile.close()

# Returns the chunk of the map from the file
func _chunk_map(chunkX, chunkY):
	var chunkID = chunkRef.find(Vector2i(chunkX, chunkY))
	chunkMapFile.seek(BYTES_IN_CHUNK * chunkID)
	var chunk: PackedByteArray = chunkMapFile.get_buffer(BYTES_IN_CHUNK)
	return chunk

func _physics_process(_delta: float) -> void:
	
	# manually trigger save
	if Input.is_action_just_pressed("save"):
		_save_map(Global.save)

# returns the data for an empty chunk
func _empty_chunk():
	
	var empty = PackedByteArray()
	
	for i in range(CHUNK_LENGTH):
		
		for j in range(CHUNK_LENGTH):
			empty.append(99)
	
	return empty

# returns the data for chunk full of dirt
func _dirt_chunk():
	
	var empty = PackedByteArray()
	
	for i in range(CHUNK_LENGTH):
		
		for j in range(CHUNK_LENGTH):
			empty.append(1)
	
	return empty
