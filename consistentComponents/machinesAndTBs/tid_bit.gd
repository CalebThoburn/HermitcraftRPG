extends Sprite2D

const TYPE = "TB" # type of node, used for running code

var code = {} # dict of funcs to list of code for given TB

var variables = {
	# things that don't really change after the mechanism is made, but I guess they could
	"wireConnections": {}, # names of outputs to wired TB
	"pos": Vector2(), # the internal pos of this TB
	"tidbit": null,
	"MECH": null, # the parent of this node, ie: the mech containing this TB

	# values that will change as the TB interacts within the Mechanism
	"powered": false, # whether the TB is powered
	"item": -1, # the list of things in this TB
}

func _ready() -> void:
	# set MECH in vars as parent of TB, that is, the mech this TB is part of
	variables["MECH"] = get_parent()
	
	# set frame
	frame = Global.tidbitsFirstFrame[variables["tidbit"]]
	
	# load the function of this tidbit
	if Global.tidbitsInfo[variables["tidbit"]].has("code"):
		code["tick"] = Global.tidbitsInfo[variables["tidbit"]]["code"]

# run the particular function of this TidBit in a tick
func _tick() -> void:
	Global.run_code(code["tick"], self)
