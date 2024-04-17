extends CharacterBody2D

const BOOM = preload("res://audioScenes/boom.tscn")
const NON_TRIGGERS = ["boom_beatle", "item"]
const CREATURE = "boom_beatle"
const SPARK = preload("res://scenes/Spark.tscn")
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
	
	_animate_spark(delta)
	
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

func _boom():
	var boom = BOOM.instantiate()
	get_parent().add_child(boom)
	
	for spark in range(100):
		_spark(position, bool(randi_range(0, 1)), true)
	
	for body in inRange:
		body.velocity += (body.position - position + Vector2(0, 8)).normalized() * BLAST_POWER
		
	queue_free()

func _animate_spark(delta):
	$BoomBeatleSprite/Spark.modulate -= Color(0, .4, .4, 0) * delta * glowDirec
	
	if $BoomBeatleSprite/Spark.modulate.g < .4 or $BoomBeatleSprite/Spark.modulate.g >= 1:
		glowDirec = glowDirec * -1
	
	if randi_range(1, 10 /delta) == 10:
		$BoomBeatleSprite.flip_h = bool(-(int($BoomBeatleSprite.flip_h) - .5) + .5)
		$BoomBeatleSprite/Spark.position *= Vector2(-1, 1)
	
	if randi_range(1, 2 / delta) == 2:
		_spark($BoomBeatleSprite/Spark.position + position, $BoomBeatleSprite.flip_h, false)

func _spark(origin, direction, boom):
	var spark = SPARK.instantiate()
	spark.boom = boom
	spark.position = origin
	spark.direction = direction
	get_parent().add_child(spark)

func _on_blast_radius_body_entered(body):
	inRange.append(body)

func _on_blast_radius_body_exited(body):
	inRange.remove_at(inRange.find(body))

func _on_boom_radius_body_entered(body):
	
	if !NON_TRIGGERS.has(body.CREATURE):
		
		_boom()

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
	print(damage)
	health -= damage
	
	if health <= 0:
		_boom()
