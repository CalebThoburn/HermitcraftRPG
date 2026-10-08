extends Area2D

# the min and max positions that the collision corners may be
const MAX = Vector2(45, 54)
const MIN = Vector2(7, 16)
const STEP = (MAX - MIN) / Global.TILE_PIXEL_SIZE.x

var mouseIn = false
var dragging = false

func _physics_process(delta: float) -> void:
	
	if Input.is_action_just_pressed("click") and mouseIn:
		dragging = true
	
	if Input.is_action_just_released("click"):
		dragging = false
	
	if dragging:
		position = get_parent().get_local_mouse_position()
	
	if position.x > MAX.x:
		position.x = MAX.x
	
	if position.x < MIN.x:
		position.x = MIN.x
	
	if position.y > MAX.y:
		position.y = MAX.y
	
	if position.y < MIN.y:
		position.y = MIN.y
	
	position = position.snapped(STEP)

func _on_mouse_entered() -> void:
	mouseIn = true

func _on_mouse_exited() -> void:
	mouseIn = false
