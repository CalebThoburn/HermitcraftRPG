extends CharacterBody2D

const CRETURE = "BoomBeatle"
const SPARK = preload("res://scenes/Spark.tscn")
const GRAVITY = 300.0
const BOOM_DAMAGE = 3

var inventory = [[["air", 0]]]
var glowDirec = 1

func _physics_process(delta):
	
	_animate_spark(delta)
	
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	move_and_slide()

func _boom(body):
	
	if body.CRETURE != "BoomBeatle":
		
		for spark in range(10):
			_spark(position, bool(randi_range(0, 1)))
		
		body._damage(BOOM_DAMAGE)
		queue_free()

func _animate_spark(delta):
	$BoomBeatleSprite/Spark.modulate -= Color(0, .4, .4, 0) * delta * glowDirec
	
	if $BoomBeatleSprite/Spark.modulate.g < .4 or $BoomBeatleSprite/Spark.modulate.g >= 1:
		glowDirec = glowDirec * -1
	
	if randi_range(1, 10 /delta) == 10:
		$BoomBeatleSprite.flip_h = bool(-(int($BoomBeatleSprite.flip_h) - .5) + .5)
		$BoomBeatleSprite/Spark.position *= Vector2(-1, 1)
	
	if randi_range(1, 2 / delta) == 2:
		_spark($BoomBeatleSprite/Spark.position + position, $BoomBeatleSprite.flip_h)

func _spark(origin, direction):
	var spark = SPARK.instantiate()
	spark.position = origin
	spark.direction = direction
	get_parent().add_child(spark)
