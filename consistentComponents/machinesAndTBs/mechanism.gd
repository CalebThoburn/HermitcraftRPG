extends CharacterBody2D

const TIDBIT = preload("res://consistentComponents/machinesAndTBs/tid_bit.tscn")
const TBSpacing = 3.0
const TYPE = "Mech" # type of node, used for running code

var blueprint = {} # the dict of internal coords to TidBit there
var variables = {
	"vel": Vector2(0, 0), # velocity
	"pos": Vector2(0, 0) # position
} # just as tidbits have vars they can read, mechanism should have vars

func _ready() -> void:
	Global.mechanisms.append(self)

# tick each TB
func tick():
	variables["pos"] = position
	
	if variables["vel"].length() <= 1:
		variables["vel"] = Vector2(0, 0)
	
	else:
		variables["vel"] = variables["vel"].limit_length(pow(variables["vel"].length(), 9.0/10.0))
	
	for coords in blueprint:
		var TB = blueprint[coords]
		
		if TB.code:
			TB._tick()
	
	velocity = variables["vel"] * Global.TICK_LENGTH
	
	move_and_slide()

# sets up the mechanism off of a blueprint (bitsPrint)
func _construct(bitsPrint):
	
	for coords in bitsPrint:
		var TB =  TIDBIT.instantiate()
		TB.position = coords * TBSpacing
		
		TB.variables["pos"] = Vector2(coords)
		
		for variable in bitsPrint[coords].keys():
			TB.variables[variable] = bitsPrint[coords][variable]
		
		blueprint[coords] = TB
		add_child(TB)
