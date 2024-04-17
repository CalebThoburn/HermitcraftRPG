extends CharacterBody2D

const GRAVITY = 300.0
const MAX_LENGTH = 50
const MIN_LENGTH = 25
const X_DECEL = 25
const BOOM_MAX_LENGTH = 200
const BOOM_MIN_LENGTH = 25

var direction
var boom

func _ready():
	
	if boom:
		velocity = Vector2(randf_range(BOOM_MIN_LENGTH, BOOM_MAX_LENGTH), 0).rotated(randf_range(-PI, -PI/2)).rotated(int(direction) * PI / 2)
		
	else:
		velocity = Vector2(randf_range(MIN_LENGTH, MAX_LENGTH), 0).rotated(randf_range(-PI, -PI/2)).rotated(int(direction) * PI / 2)

func _physics_process(delta):
	
	if X_DECEL * delta >= abs(velocity.x):
		velocity.x = 0
		
	else:
		velocity.x -= sign(velocity.x) * X_DECEL * delta
	
	_animate_spark(delta)
	
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	move_and_slide()

func _boom(body):
	queue_free()

func _animate_spark(delta):
	$SparkSprite.modulate -= Color(0, .4, .4, .8) * delta
	
	if $SparkSprite.modulate.a <= 0:
		queue_free()
