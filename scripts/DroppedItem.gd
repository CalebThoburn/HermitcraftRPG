extends CharacterBody2D

const LOOP_TIME = 3000.0
const LOOP_DISTANCE = 10.0
const GRAVITY = 300.0
const ITEMS = ["grass", "dirt", "sand", "gravel", "stone", "coal_ore", "iron_ore", "diamond_ore", "leaves", "log", "stripped_log", "plank", "crafting_table", "barrel", "post", "glass", "flint", "coal", "diamond", "apple", "sapling", "stone_sword", "iron_sword", "diamond_sword", "slab", "wool", "red_wool"]
 
var pickUpCooldown = .5
var item
var startTime
var bodiesTouching = []

func _ready():
	startTime = Time.get_ticks_msec()
	$ItemSprite.frame = ITEMS.find(item)

func _process(delta):
	pickUpCooldown -= delta
	_move_sprite()
	velocity.y += GRAVITY * delta
	
	if is_on_floor():
		velocity.y = 0
		
	move_and_slide()
	
	if pickUpCooldown < 0 and bodiesTouching.size() > 0:
		var body = bodiesTouching[0]
		var done = false
		
		for row in range(body.inventory.size()):
			
			if done:
				break
			
			for index in range(body.inventory[row].size()):
				var slot = body.inventory[row][index]
				
				if slot[0] == item and slot[1] < 64:
					body.inventory[row][index][1] += 1
					queue_free()
					done = true
					break
			
				elif slot[0] == "air":
					body.inventory[row][index] = [item, 1]
					get_node("../../Player")._update_hotbar()
					queue_free()
					done = true
					break

func _move_sprite():
	$ItemSprite.position.y = _ease_in_out_sin(fmod(Time.get_ticks_msec() - startTime, LOOP_TIME) / LOOP_TIME - .5) * LOOP_DISTANCE - LOOP_DISTANCE / 1.9

func _ease_in_out_sin(progress):
	return( -(cos(PI * progress) - 1) / 2)

func _on_item_pickup_body_entered(body):
	bodiesTouching.append(body)

func _on_item_pickup_body_exited(body):
	bodiesTouching.erase(body)
