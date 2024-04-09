extends Node2D

const HANG = .5
const POINT = preload("res://scenes/point.tscn")

var color
var origin
var end
var from
var to
var attached = false

func _ready():
	_update()

func _physics_process(delta):
	_update()

func _update():
	
	for child in get_children():
		child.queue_free()
	
	if !attached:
		end = get_local_mouse_position() + Vector2(1, 0)
	
	var start_x
	var end_x
	
	if end.x > origin.x:
		start_x = origin.x
		end_x = end.x
		
	else:
		start_x = end.x
		end_x = origin.x
	
	for x in range(start_x, end_x + 1):
		
		if round(_ellipses_y_at_x(x)) < round(_ellipses_y_at_x(x + 1)) + 1:
			
			for y in range(round(_ellipses_y_at_x(x) - 1) , round(_ellipses_y_at_x(x + 1))):
				var point = POINT.instantiate()
				point.position.x = x
				point.position.y = y
				point.frame = color
				add_child(point)
		else:
			
			if (_ellipses_y_at_x(x) < 0 or _ellipses_y_at_x(x ) > 0 or _ellipses_y_at_x(x) == 0):
				
				for y in range(round(_ellipses_y_at_x(x) - 1) , round(_ellipses_y_at_x(x - 1))):
					var point = POINT.instantiate()
					point.position.x = x
					point.position.y = y
					point.frame = color
					add_child(point)
	
func _ellipses_y_at_x(x):
	var o
	var c
	
#	if end.y > origin.y and end.x > origin.x and 3 == 1:
#		var k = 1 - pow(end.y - origin.y, 2) / pow(end.y - origin.y + HANG, 2)
#		var a = k - 1
#		var b = 2 * end.x - 2 * origin.x * k
#		var c = -(pow(end.x, 2) - pow(k * origin.x, 2))
#		var factored = (-b + sqrt(pow(b, 2) - 4 * a * c)) / (2 * a)
#		top = Vector2(factored, end.y + HANG)
		
	if end.y < origin.y:
		c = Vector2(origin.x, end.y)
		o = Vector2(end.x, origin.y)
		
	else:
		c = Vector2(end.x, origin.y)
		o = Vector2(origin.x, end.y)
	
	var result = c.y + sqrt(abs(pow(o.y - c.y, 2)) * ((-pow(x - c.x, 2) / abs(pow(o.x - c.x, 2))) + 1))
	
	return result
