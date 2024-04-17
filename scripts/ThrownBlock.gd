extends CharacterBody2D

const BLOCK_FRAME = ["grass", "dirt", "sand", "gravel", "stone", "coal_ore", "iron_ore", "diamond_ore", "leaves", "log", "stripped_log", "plank", "crafting_table", "barrel", "post", "glass", "thick_leaves", "slab", "wool", "red_wool", "save_block", "cobweb"]
const CREATURE = "block"
const GRAVITY = 300.0
const DECELERATION = Vector2(300.0, 0.0)

var block
var inventory = []

func _ready():
	$BlockSprite.frame = BLOCK_FRAME.find(block)
	

func _physics_process(delta):
	_decel(delta)
	_gravity(delta)
	move_and_slide()
	
	if velocity == Vector2(0, 0):
		_place()

func _place():
	get_node("../TileMap")._place(block, get_node("../TileMap").local_to_map(position))
	queue_free()

func _decel(delta):
	
	if abs(velocity.x) < DECELERATION.x * delta:
		velocity.x = 0
	
	else:
		velocity.x -= sign(velocity.x) * DECELERATION.x * delta
	
	if abs(velocity.y) < DECELERATION.y * delta:
		velocity.y = 0
	
	else:
		velocity.y -= sign(velocity.y) * DECELERATION.y * delta

func _gravity(delta):
	
	if !is_on_floor():
		velocity.y += GRAVITY * delta
	
	else:
		velocity.y = 0

func _damage(damage):
	pass
