extends CharacterBody2D

const SPEED = 9000.0
const DEV_SPEED = 150.0
const JUMP_VELOCITY = -250.0

var tidbits = {
	"tip": 1,
	"funnel": 2,
	"barrel": 1,
	"shaft": 6,
	"trigger": 7,
	"wheel": 5
} # the list of TBs the player has and how many

func _ready() -> void:
	Global.PLAYER = self

func _physics_process(delta: float) -> void:
	
	# survival controls if DevMode is not activated
	if Global.playerAction == Global.Actions.NULL:
		_movement(delta)
	
	# dev controls if DevMode is active
	else:
		_dev_movement(delta)
	
	# toggle dev
	if Input.is_action_just_pressed('toggleDev'):
		
		# if off, turn on
		if Global.playerAction == Global.Actions.NULL:
			Global.playerAction = Global.Actions.PLACE
		
		# if on, turn off
		else:
			Global.playerAction = Global.Actions.NULL

func _movement(delta):
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump
	if Input.is_action_just_pressed("up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	var dirX := Input.get_axis("left", "right")
	
	if dirX:
		velocity.x = dirX * SPEED * delta
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()

func _dev_movement(delta):
	var dirX := Input.get_axis("left", "right")
	var dirY := Input.get_axis("up", "down")
	
	if dirX:
		velocity.x = dirX * DEV_SPEED * delta
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if dirY:
		velocity.y = dirY * DEV_SPEED * delta
	else:
		velocity.y = move_toward(velocity.x, 0, SPEED)

	position += velocity
	velocity = Vector2(0, 0)
