extends Node2D

const BITS = ["tip", "funnel_b", "funnel_r", "funnel_l", "barrel", "shaft", "trigger_l", "trigger_t", "trigger_r", "trigger_b", "wheel", "handle", "computer_xor", "computer_and", "computer_flip", "antenna_1", "antenna_2", "glass"]

var row # -1 for mouse
var index # -1 for sidebar
var info = {}
var item = ["air", 0]

var touchingMouse = false

@onready var tileMap = get_node("../../")

func _ready():
	
	_update_bit()
	position.y = index * get_parent().SPACING + get_parent().INITIAL_Y
	position.x = row * get_parent().SPACING + get_parent().INITIAL_X
	
	
	if row == -1:
		position = get_parent().get_local_mouse_position()
	
	if info["bit"] == "computer":
		$ItemSprite.frame = BITS.find(info["type"])
		
	else:
		$ItemSprite.frame = BITS.find(info["bit"])

func _process(delta):
	
	if get_parent().mouseItem == self:
		z_index = 2
		
	else:
		z_index = 0
	
	_crafting_menu_stuff()
	
	if row == -1:
		z_index = 1
		position = get_parent().get_local_mouse_position()
	
	else:
		z_index = 0
		position.y = index * get_parent().SPACING + get_parent().INITIAL_Y
		position.x = row * get_parent().SPACING + get_parent().INITIAL_X

func _crafting_menu_stuff():
	
	position.y = index * get_parent().SPACING + get_parent().INITIAL_Y
	position.x = row * get_parent().SPACING + get_parent().INITIAL_X

func _on_mouse_detecter_mouse_entered():
	touchingMouse = true

func _on_mouse_detecter_mouse_exited():
	touchingMouse = false

func _update_bit():
	
	if info["bit"] == "trigger" or info["bit"] == "funnel":
		
			if info["anchor"] == null:
				$ItemSprite.frame = BITS.find(info["bit"] + "_b")
				
			else:
				$ItemSprite.frame = BITS.find(info["bit"] + "_" + info["anchor"])
