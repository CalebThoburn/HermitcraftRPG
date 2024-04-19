extends CharacterBody2D

const CREATURE = "guy"
const GRAVITY = 300.0
const BLAST_POWER = 400
const DECELERATION = Vector2(300.0, 0.0)
const DECEL_PER_DAMAGE = 100.0 * sqrt(17)

var effects = {"slowness": 0}
var inRange = []
var inventory = [[["air", 0]]]
var glowDirec = 1
var health = 1

@onready var lastVel = velocity

func _physics_process(delta):
	
	_update_effects(delta)
	
	_move(delta)
	
	move_and_slide()

func _move(delta):
	
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	if abs(velocity.x) < DECELERATION.x * delta:
		velocity.x = 0
	
	else:
		velocity.x -= sign(velocity.x) * DECELERATION.x * delta
	
	if abs(velocity.y) < DECELERATION.y * delta:
		velocity.y = 0
	
	else:
		velocity.y -= sign(velocity.y) * DECELERATION.y * delta

func _update_effects(delta):
	
	for effect in effects.keys():
		
		effects[effect] -= delta
		
		if effects[effect] < 0:
			effects[effect] = 0
			
			match effect:
				
				"slowness":
					pass

func _effect(effect, duration):
	
	effects[effect] += duration
	
	match effect:
		
		"slowness":
			
			get_node("../TileMap")._drop("boom_beatle", 1, position)
			queue_free()

func _decel_damage(delta):
	_damage(round(abs(velocity - lastVel).length() / delta / DECEL_PER_DAMAGE))
	lastVel = velocity

func _damage(damage):
	health -= damage
	
	if health <= 0:
		queue_free()
