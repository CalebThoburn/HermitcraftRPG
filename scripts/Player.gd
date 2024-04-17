extends CharacterBody2D

const DAMAGE_COOLDOWN = .25
const DECEL_PER_DAMAGE = 20000.0
const CREATURE = "Player"
const HOTBAR_CHILDREN = ["HFBars", "SelectedSlot", "MouseDetecter", "InventorySprite"]
const COLLECTED_ITEM = preload("res://scenes/collected_item.tscn")
const ARM_FRAME_OFFSETS = [Vector2(-2, 1), Vector2(-1, 1), Vector2(.5, 2), Vector2(1.5, 1.5), Vector2(3, .5)]
const MAX_SPEED = 80.0
const ACCELERATION = 600.0
const JUMP_VELOCITY = -90.0
const JUMP_TIME = .05
const GRAVITY = 300.0
const DECELERATION = 300.0
const HOTBAR_SLOTS = 4
const SWORDS = ["stone_sword", "iron_sword", "diamond_sword"]

var effects = {"slowness": 0}
var speedFactor = 1
var lastPos = Vector2(0, 0)
var lastDamage = [0, 0.0]
var lastVel = Vector2(0, 0)
var health = 8
var fullness = 8
var slot = 0
var swordCooldown = 0.0
var cursorItemOrigin = [0, 0]
var lastDirection = 1
var facing = 1
var cursor = ["air", 0]
var inventory = [
	[["air", 0], ["air", 0], ["air", 0], ["air", 0]],
	[["air", 0], ["air", 0], ["air", 0], ["air", 0]]]
var crafting = false
var jumping = false
var jumpedHeight = 0

func _physics_process(delta):
	_decel_damage(delta)
	_update_slot()
	_move(delta)
	_animate_arms(delta)
	
	if float(Time.get_ticks_msec()) / 1000 - lastDamage[1] < DAMAGE_COOLDOWN:
		$Torso.modulate.s = 80
		
	else:
		$Torso.modulate.s = 0

func _update_hotbar():
	
	$HotBar.inventory = [[null, null, null, null, ],[null, null, null, null, ]]
	
	for child in $HotBar.get_children():
		
		if !HOTBAR_CHILDREN.has(child.name):
			
			if child.row != -1:
				child.queue_free()
	
	for row in range(inventory.size()):
		
		for index in range(inventory[row].size()):
			
			if inventory[row][index] != ["air", 0]:
				var item = COLLECTED_ITEM.instantiate()
				item.index = index
				item.row = row
				item.item = inventory[row][index][0]
				
				if item.item == "invention":
					item.blueprint = inventory[row][index][2]
					item.anchors = inventory[row][index][3]
					item.activations = inventory[row][index][4]
					item.items = inventory[row][index][5]
				
				$HotBar.inventory[row][index] = item
				$HotBar.add_child(item)

func _update_slot():
	
	if Input.is_action_just_pressed("one"):
		slot = 0
		
	elif Input.is_action_just_pressed("two"):
		slot = 1
		
	elif Input.is_action_just_pressed("three"):
		slot = 2
		
	elif Input.is_action_just_pressed("four"):
		slot = 3

func _animate_arms(delta):   
	
	if Input.is_action_pressed("left") or Input.is_action_pressed("right"):
		$BackArmAnimation.play("Walk")
		$BackArmAnimation.seek($LegsAnimation.current_animation_position)
	
	else:
		$BackArmAnimation.play("RESET")
			
	if Input.is_action_pressed("click") and !$HotBar.mouseInInventory and !crafting:
		$FrontArmAnimation.play("Action")
		
	elif inventory[0][slot][0] != "invention" and (Input.is_action_pressed("left") or Input.is_action_pressed("right")):
		$FrontArmAnimation.play("Walk")
		$FrontArmAnimation.seek($LegsAnimation.current_animation_position)
		
	else:
		$FrontArmAnimation.play("RESET")
	
	if inventory[0][slot][0] == "invention":
		$FrontArmAnimation.play("Holding")
		$Torso/FrontArm/HeldInvention._update()
		$Torso/FrontArm/HeldInvention.show()
		$Torso/FrontArm.offset = Vector2(3.5, 0)
		$Torso/FrontArm.position = Vector2(0, -3)
		$Torso/FrontArm.frame = 5
		$Torso/FrontArm.flip_h = false
		
		if get_local_mouse_position().x * $Torso.scale.x > 0:
			$Torso/FrontArm.look_at(get_global_mouse_position())
		
		else:
			$Torso/FrontArm.look_at(Vector2(0, -1) + position)
		
	else:
		$Torso/FrontArm.flip_h = true
		$Torso/FrontArm/HeldInvention.hide()
		$Torso/FrontArm.position = Vector2(-.5, -1.5)
		$Torso/FrontArm.rotation = 0

func _move(delta):
	
	_update_effects(delta)
	
	if !is_on_floor() and !jumping:
		velocity.y += GRAVITY * delta
	
	if Input.is_action_pressed("shift"):
		set_collision_layer_value(3, false)
		set_collision_mask_value(3, false)
		
	else:
		set_collision_layer_value(3, true)
		set_collision_mask_value(3, true)
	
	if Input.is_action_pressed("jump") and is_on_floor() and !jumping:
		jumping = true
		jumpedHeight = 0
		
	if jumping:
		velocity.y += JUMP_VELOCITY * delta / JUMP_TIME
		jumpedHeight += abs(JUMP_VELOCITY * delta) / JUMP_TIME
		
		if jumpedHeight >= abs(JUMP_VELOCITY):
			jumping = false
		
	if Input.is_action_pressed("right") and velocity.x < MAX_SPEED * speedFactor:
		
		$LegsAnimation.play("Walk")
		velocity.x += ACCELERATION * delta * speedFactor
		
		if velocity.x > MAX_SPEED * speedFactor:
			velocity.x = MAX_SPEED * speedFactor
		
	elif Input.is_action_pressed("left") and velocity.x > -MAX_SPEED * speedFactor:
			
		$LegsAnimation.play("Walk")
		velocity.x -= ACCELERATION * delta * speedFactor
		
		if velocity.x < -MAX_SPEED * speedFactor:
			velocity.x = -MAX_SPEED * speedFactor
		
	else:
		$LegsAnimation.play("RESET")
	
	if velocity.x == 0:
		velocity.x = .01
	
	lastDirection = velocity.x / abs(velocity.x)
	
	velocity.x -= DECELERATION * lastDirection * delta * speedFactor
	
	if velocity.x * lastDirection < 0:
		velocity.x = 0
	
	move_and_slide()
	
	if facing != sign(get_global_mouse_position().x - position.x) and get_global_mouse_position().x - position.x != 0:
		facing *= -1
		$LegsAnimation.play("RESET")
		$FrontArmAnimation.play("RESET")
		$BackArmAnimation.play("RESET")
		$Torso.scale.x = facing
	
	if $WalkSounds.tileMap.BLOCK_FRAME[$WalkSounds.targetAtlas.x + $WalkSounds.targetAtlas.y * 8] == "air":
		$WalkSounds.stop()
	
	elif (Input.is_action_pressed("right") or Input.is_action_pressed("left")) and $WalkSounds.cooldown == 0:
		$WalkSounds._play()

func _damage(damage):
	
	var total_damage = 0
	
	if float(Time.get_ticks_msec()) / 1000 - lastDamage[0] > DAMAGE_COOLDOWN:
		total_damage = damage
		lastDamage = [damage, float(Time.get_ticks_msec()) / 1000]
	
	elif lastDamage[0] < damage:
		total_damage = damage - lastDamage[0]
		lastDamage = [damage, float(Time.get_ticks_msec()) / 1000]
	
	health -= total_damage
	$HotBar._update_hf()
	$Damage.play()
	$DamageAnimation.play("damage")

func _decel_damage(delta):
	
	if round((velocity - lastVel).length() / DECEL_PER_DAMAGE / delta) != 0:
		_damage(round((velocity - lastVel).length() / DECEL_PER_DAMAGE / delta))
	
	lastVel = velocity

func _update_effects(delta):
	
	for effect in effects.keys():
		
		effects[effect] -= delta
		
		if effects[effect] < 0:
			effects[effect] = 0
			
			match effect:
				
				"slowness":
					speedFactor = 1

func _effect(effect, duration):
	
	effects[effect] += duration
	
	match effect:
		
		"slowness":
			
			speedFactor = .5
