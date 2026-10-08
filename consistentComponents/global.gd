extends Node2D

const TICK_LENGTH = .05 # the length of game ticks, (mechanism tick each TB once per game tick) (blocks can execute code once per tick)
var ttNtick = 0.0 # time till next tick

## references to nodes, set by the nodes themselves
var TILE_MAP
var DEV_COMPS # the node that fathers all dev tool nodes,
var PLAYER

var mechanisms = []
var variables = {} ## DELETE THIS
## vars for loading the world
var blockSetTexture: Texture2D # the current blockSet texture

const BLOCKS_IN_ROW = 8 # the number of blocks per row of the spritesheet
const TILE_PIXEL_SIZE = Vector2i(12, 12)

var modFilePath = "res://mods/default" # the path to the folder for the set of blocks items etc to be used
var save = "save1" # the currently loaded save file
var blockInfo = {} # properties of each block: [collision, durability]
var tidbitsInfo = {
	"tip": {"code": ["if item != -1:2", "place(item, grid(MECH.pos()))"]},
	"funnel": {"code": ["coords(pos+dir).item = coords(pos+Vector(0,-1)).item", "coords(pos+Vector(0,-1)).item = 0)"], "dirs": [Vector2(0, 1), Vector2(1, 0), Vector2(-1, 0)]},
	"barrel": {"code": ["coords(pos).item = 10"]},
	"shaft": {},
	"trigger": {"dirs": [Vector2(-1, 0), Vector2(1, 0), Vector2(1, 0), Vector2(0, -1)]},
	"wheel": {"code": ["propell(1000, 0)"]},
	"handle": {},
	"xorGate": {},
} # the info such as code for a given tidbit
var tidbitsFirstFrame = {} # tidbit keys to first frame of theirs

var tileSetSourceId

## vars for player comunication, between menus and cursors and such
enum Actions {
	# Dev actions
	PLACE,
	EDIT,
	PICK,
	# 'Survival' actions
	NULL,
	CRAFTING,
} # the different states the player can be in for dev
var playerAction: Actions = Actions.PLACE
var devTile # the block the player will place when in dev mode

func _ready() -> void:
	# load blockSet
	blockSetTexture = load(modFilePath + "/blocks/blockset.png")
	
	# load block info
	var blockInfoFile = FileAccess.open(modFilePath + "/blocks/blockInfo.txt", FileAccess.READ)
	blockInfo = blockInfoFile.get_var()
	blockInfoFile.close()
	
	# set tidbitsFirstFrame
	var frame = 0
	
	for tb in tidbitsInfo.keys():
		tidbitsFirstFrame[tb] = frame
		
		if tidbitsInfo[tb].keys().has("dirs"):
			frame += tidbitsInfo[tb]["dirs"].size()
		
		else: 
			frame += 1

const MAX_TICKS_PER_FRAME = 5
func _process(delta: float) -> void:
	ttNtick -= delta
	var ticksThisFrame = 0
	
	if ttNtick <= 0.0:
		
		while ttNtick <= 0 and ticksThisFrame < MAX_TICKS_PER_FRAME:
			ttNtick += TICK_LENGTH
			ticksThisFrame += 1
			
			for mech in mechanisms:
				mech.tick()
			
			for x in range(-1, 2):
				
				for y in range(-1, 2):
					
					var chunk = Vector2i(floor(PLAYER.position / float(TILE_MAP.CHUNK_LENGTH) / Vector2(TILE_MAP.tile_set.tile_size))) + Vector2i(x, y)
					var chunkByteArray = []
					
					if TILE_MAP.chunkDict.keys().has(chunk):
						chunkByteArray = TILE_MAP.chunkDict[chunk]
				
					else:
						chunkByteArray = TILE_MAP._chunk_map(chunk.x, chunk.y)
						
					
					for index in chunkByteArray.size():
						var block = chunkByteArray[index]
						
						if blockInfo.size() > block and blockInfo[blockInfo.keys()[block]].keys().has("code"):
							# because run_code() requires a node argument for what is being run, a dummyNode is created to store the informaiton and changes for the block
							var dummyBlockNode = dummyBlock.new()
							dummyBlockNode.variables["id"] = block
							var blockY = floor(index / TILE_MAP.CHUNK_LENGTH)
							var blockX = index - blockY * TILE_MAP.CHUNK_LENGTH
							dummyBlockNode.position = chunk * TILE_MAP.CHUNK_LENGTH + Vector2i(blockX, blockY)
							run_code(blockInfo[blockInfo.keys()[block]]["code"], dummyBlockNode)
		
		if ttNtick <= 0:
			ttNtick = TICK_LENGTH

# triggered by various engine-level callbacks, used here to save game when window is told close
func _notification(what: int) -> void:
	
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()

func save_game():
	# save map
	TILE_MAP._save_map(save)
	
	# save block info
	var blockInfoFile = FileAccess.open(modFilePath + "/blocks/blockInfo.txt", FileAccess.WRITE)
	blockInfoFile.store_var(blockInfo)
	blockInfoFile.close()
	
	# save TB info
	var tidbitInfoFile = FileAccess.open(modFilePath + "/machinesAndTBs/tidbitInfo.txt", FileAccess.WRITE)
	tidbitInfoFile.store_var(tidbitsInfo)

# runs some code through once
func run_code(code, node):
	var lineNum = -1
	
	while lineNum + 1 < code.size():
		lineNum += 1
		var line = code[lineNum]
		
		# testing for values
		if line.left(2) == "if":
			
			if line.contains("=="):
				# split line into bool and line to skip to
				var splitLine = line.split(":")
				var lineToSkipToOnFalse = int(splitLine[1])
				
				# break Bool into two values to test if equal
				var splitBool = splitLine[0].split("==")
				var valueOne = _eval(splitBool[0].trim_prefix("if"), node)
				var valueTwo = _eval(splitBool[1], node)
				
				# test if equal
				if valueOne == valueTwo:
					pass
				
				else:
					lineNum = lineToSkipToOnFalse
			
			elif line.contains("!="):
				# split line into bool and line to skip to
				var splitLine = line.split(":")
				var lineToSkipToOnFalse = int(splitLine[1])
				
				# break Bool into two values to test if un-equal
				var splitBool = splitLine[0].split("!=")
				var valueOne = _eval(splitBool[0].trim_prefix("if"), node)
				var valueTwo = _eval(splitBool[1], node)
				
				# test if un-equal
				if valueOne != valueTwo:
					pass
				
				else:
					lineNum = lineToSkipToOnFalse
			
			elif line.contains(">"):
				# split line into bool and line to skip to
				var splitLine = line.split(":")
				var lineToSkipToOnFalse = int(splitLine[1])
				
				# break Bool into two values to test if greater
				var splitBool = splitLine[0].split(">")
				var valueOne = _eval(splitBool[0].trim_prefix("if"), node)
				var valueTwo = _eval(splitBool[1], node)
				
				# test if greater
				if valueOne > valueTwo:
					pass
				
				else:
					lineNum = lineToSkipToOnFalse
			
			elif line.contains("<"):
				# split line into bool and line to skip to
				var splitLine = line.split(":")
				var lineToSkipToOnFalse = int(splitLine[1])
				
				# break Bool into two values to test if lesser
				var splitBool = splitLine[0].split("<")
				var valueOne = _eval(splitBool[0].trim_prefix("if"), node)
				var valueTwo = _eval(splitBool[1], node)
				
				# test if lesser
				if valueOne < valueTwo:
					pass
				
				else:
					lineNum = lineToSkipToOnFalse
			
		# placing block: place(block, loc)
		elif line.left(5) == "place":
			
			var args = _break_into_args(line.trim_prefix("place(").trim_suffix(")"))
			var blockToPlace = _eval(args[0], node)
			var blockPosition = _eval(args[1], node)
			TILE_MAP.place_block_by_ID(blockToPlace, blockPosition)
		
		# setting vars
		elif line.contains("="):
			# break line into var to set and value to set to
			var splitLine = line.split("=")
			var nodeVarArgComboToSet = _eval(splitLine[0], node, true)
			var variableToSet = nodeVarArgComboToSet["var"]
#			var argForVarToSet = nodeVarArgComboToSet["arg"]
			var nodeToSetVarOn = nodeVarArgComboToSet["node"]
			
			var valueToSetTo = _eval(splitLine[1], node)
			
			if variableToSet.contains("["):
				# split var up by args for lists and dicts
				var arrayArgs = variableToSet.split("[")
				var array = arrayArgs[0] # the very first phrase which is the var name
				arrayArgs.remove_at(0) # remove array name from list of args
				
				# turn args from vars into nums with _eval
				var values = []
				
				for phrase in arrayArgs:
					values.append(_eval(phrase.strip_edges().rstrip("]"), node))
				
				# remove the last value and save for later, then get the array/var/dict at the end of line to set in one step
				var lastValue = values[-1]
				values.remove_at(-1)
				
				variableToSet = node.variables[array]
				
				for arg in values:
					variableToSet = variableToSet[arg]
				
				variableToSet[lastValue] = valueToSetTo
			
			else:
				nodeToSetVarOn.variables[variableToSet.strip_edges()] = valueToSetTo
		
		# printing info: print(var)
		elif line.left(5) == "print":
			# get and evaluate everything after print and then, print it
			var phraseToPrint = line.trim_prefix("print(").trim_suffix(")")
			print("Printing from TB: " + str(_eval(phraseToPrint, node)))
		
		else:
			# look at type specific functions
			match node.TYPE:
				
				"TB":
					
					# propell mech (add to velocity): propell(x, y):
					if line.left(7) == "propell":
						var args = line.trim_prefix("propell(").trim_suffix(")").split(",")
						var x = _eval(args[0], node)
						var y = _eval(args[1], node)
						node.get_parent().variables["vel"] += Vector2(x, y)

# takes a 'phrase' and returns the value
func _eval(phrase, node, passByReference = false):
	
	# break phrase into smaller phrases with operations between them
	var depth = 0
	var currentPhrase = ""
	var phrases = []
	var operations = {
		"*": [], 
		"/": [],
		"+": [],
		"-": []
	}
	var nodes = {}
	
	for index in range(phrase.length()):
		var character = phrase[index]
		
		match character:
			
			"[", "(": # if opening new parenthetical phrase
				depth += 1
				currentPhrase += character
			
			"]", ")": # if closing new parenthetical phrase
				depth -= 1
				currentPhrase += character
			
			# puts operations into another list but won't to include the operations in parentheses, as parentheticals will be evaluated on their own
			"+", "-", "/", "*" when depth == 0:
				operations[character].append(phrases.size())
				phrases.append(currentPhrase)
				currentPhrase = ""
			
			# lists the phrase before dot as node for next phrase to be looked for in
			"." when depth == 0:
				nodes[phrases.size()] = _eval(currentPhrase, node)
				currentPhrase = ""
			
			" ":
				pass
			
			_:
				currentPhrase  += character
		
		if index == phrase.length() - 1:
			phrases.append(currentPhrase)
	
	if passByReference:
		var var_and_arg = [phrases[0], null]
		
#		if phrases[0].contains("["):
#			var_and_arg = phrases[0].rstrip("]").split("[")
#			var_and_arg[1] = _eval(var_and_arg[1], node)
		
		return {"node": nodes[0], "var": var_and_arg[0], "arg": var_and_arg[1]}
	
	else:
		# replace the phrases with node/num values and such
		var values = []
		
		for phraseIndex in range(phrases.size()):
			var indvPhrase = phrases[phraseIndex]
			
			var nodeToRunOn = node
			
			## NODESTUFF
			if nodes.has(phraseIndex):
				nodeToRunOn = nodes[phraseIndex]
			
			var firstPara = indvPhrase.find("(")
			var firstBrack = indvPhrase.find("[")
			
			# if var isn't, it is put ahead of the other
			if firstPara == -1:
				firstPara = INF
				
			if firstBrack == -1:
				firstBrack = INF
			
			# if para before brack
			if firstPara < firstBrack:
				var paraClose = indvPhrase.rfind(")")
				var phraseBeforePara = indvPhrase.split("(")[0]
				var phraseInsidePara = indvPhrase.substr(firstPara + 1, paraClose - firstPara - 1)
				
				# if there is a phrase before the paranthetical, it must be evaluated as a function
				if phraseBeforePara:
					
					match phraseBeforePara:
						
						# returns the string of letters inside of it
						"str":
							values.append(phraseInsidePara)
						
						"randi":
							var bounds = _break_into_args(phraseInsidePara)
							var lowerBound = int(bounds[0])
							var upperBound = int(bounds[1])
							values.append(randi_range(lowerBound, upperBound))
							
						# returns the pos of this node
						"pos":
							values.append(nodeToRunOn.position)
						
						# returns the TB at the specified coords in this mech, takes a vector as an argument
						"coords":
							var coordsVector = _eval(phraseInsidePara, nodeToRunOn)
							values.append(node.get_parent().blueprint[Vector2i(coordsVector)])
						
						# returns a vector from the x and y in it
						"Vector":
							
							var XAndY = _break_into_args(phraseInsidePara)
							var x = _eval(XAndY[0], nodeToRunOn)
							var y = _eval(XAndY[1], nodeToRunOn)
							values.append(Vector2(x, y))
						
						# returns the grid block coords for the vector in it
						"grid":
							values.append(floor(_eval(phraseInsidePara, nodeToRunOn)/Vector2(TILE_PIXEL_SIZE)))
						
						_:
							print("urecognized function: " + phraseBeforePara)
					
				else:
					values.append(_eval(phraseInsidePara, nodeToRunOn))
			
			# if brack before para
			elif firstBrack < firstPara:
				var brackClose = indvPhrase.rfind("]")
				var phraseBeforeBrack = indvPhrase.split("[")[0]
				var phraseInsideBrack = indvPhrase.substr(firstBrack + 1, brackClose - firstBrack - 1)
				
				values.append(nodeToRunOn.variables[phraseBeforeBrack][_eval(phraseInsideBrack, nodeToRunOn)])
			
			elif nodeToRunOn.variables.has(indvPhrase):
				values.append(nodeToRunOn.variables[indvPhrase])
			
			else:
				values.append(float(indvPhrase))
		
		# actually evaluate the phrase, in PEMDAS order
		for operationType in operations.keys():
			
			for index in operations[operationType]:
				
				match operationType:
					"*":
						values[index] = values[index] * values[index + 1]
					"/":
						values[index] = values[index] / values[index + 1]
					"+":
						values[index] = values[index] + values[index + 1]
					"-":
						values[index] = values[index] - values[index + 1]
					"_":
						print("unknown operation: " + operationType)
				
				values.remove_at(index + 1)
				_telescope_values(operations, nodes, index)
		
		return values[0]

# subtracts one from all operations and nodes greater than an index 
func _telescope_values(operations, nodes, index):
	
	# * / + - etc
	for operationType in operations.keys():
		
		# the index in the dictArray of the index of the operation in values list
		for operationIndexIndex in range(operations[operationType].size()):
			var operationIndex = operations[operationType][operationIndexIndex]
			
			if operationIndex > index:
				operations[operationType][operationIndexIndex] -= 1
	
	## TRASH PROBABLY REMOVE
	var newNodes = {}
	for phraseIndex in nodes.keys():
		
		if phraseIndex > index:
			newNodes[phraseIndex - 1] = nodes[phraseIndex]
		
		else:
			newNodes[phraseIndex] = nodes[phraseIndex]
	# doesn't need to return anything, since dicts and arrays are passed by reference

# given a parenthetical statement, returns an array of the arguments within it
func _break_into_args(parenthetical):
	
	var depth = 0
	var currentPhrase = ""
	var arguments = []
	
	for character in parenthetical:
		
		match character:
			"(":
				depth += 1
				currentPhrase += character
			
			")":
				depth -= 1
				currentPhrase += character
			
			",":
				
				if depth == 0:
					arguments.append(currentPhrase)
					currentPhrase = ""
				
				else:
					currentPhrase += character
			
			" ":
				pass
			
			_:
				currentPhrase += character
	
	arguments.append(currentPhrase) # the last phrase isn't followed by a comma, so must be added sic
	
	return arguments
