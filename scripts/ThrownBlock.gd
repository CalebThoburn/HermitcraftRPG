extends CharacterBody2D

const BLOCK_FRAME = ["grass", "dirt", "sand", "gravel", "stone", "coal_ore", "iron_ore", "diamond_ore", "leaves", "log", "stripped_log", "plank", "crafting_table", "barrel", "post", "glass", "thick_leaves", "slab", "wool", "red_wool", "save_block"]
const CRETURE = "block"
const GRAVITY = 300.0
const DECELERATION = Vector2(300.0, 0.0)

var block
var inventory = []
var vel = Vector2(300, 0)

func _ready():
	$BlockSprite.frame = BLOCK_FRAME.find(block)

func _physics_process(delta):
	_decel(delta)
	_gravity(delta)
	velocity = vel
	move_and_slide()
	
	if vel == Vector2(0, 0):
		_place()

func _place():
	get_node("../TileMap")._place(block, get_node("../TileMap").local_to_map(position))
	queue_free()

func _decel(delta):
	
	if abs(vel.x) < DECELERATION.x * delta:
		vel.x = 0
	
	else:
		vel.x -= sign(vel.x) * DECELERATION.x * delta
	
	if abs(vel.y) < DECELERATION.y * delta:
		vel.y = 0
	
	else:
		vel.y -= sign(vel.y) * DECELERATION.y * delta

func _gravity(delta):
	
	if !is_on_floor():
		vel.y += GRAVITY * delta
	
	else:
		vel.y = 0

func _damage(damage):
	pass
