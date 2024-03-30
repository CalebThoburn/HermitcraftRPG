extends CharacterBody2D

const GRAVITY = 300.0
const MAX_X_VEL = -10
const MIN_X_VEL = -25
const MAX_Y_VEL = -50
const MIN_Y_VEL = -25
const X_DECEL = 25

var direction

func _ready():
	velocity = Vector2(randf_range(MIN_X_VEL, MAX_X_VEL) * 2 * -(int(direction) - .5), randf_range(MIN_Y_VEL, MAX_Y_VEL))
	
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
