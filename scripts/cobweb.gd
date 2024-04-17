extends CharacterBody2D

const DECEL_PER_DAMAGE = 100.0 * sqrt(17)
const GRAVITY = 300.0
const DECELERATION = Vector2(100.0, 100.0)

var block
var lastVel

func _ready():
	lastVel = velocity

func _physics_process(delta):
	_decel(delta)
	_gravity(delta)
	_decel_damage(delta)
	move_and_slide()

func _decel_damage(delta):
	_damage(round(abs(velocity - lastVel).length() / delta / DECEL_PER_DAMAGE))
	lastVel = velocity

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
	
	if damage > 1:
		queue_free()

func _on_stick_area_body_entered(body):
	
	body._effect("slowness", 5.0)
