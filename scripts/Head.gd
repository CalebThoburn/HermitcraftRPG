extends AnimatedSprite2D

@onready var cursor = get_node("../../../TileMap/PlayerCursor")

func _process(delta):
	
	var angle = get_angle_to(cursor.position)
	
	if angle < -.5:
		
		frame = 0
		offset = Vector2(-1, -9)
		
	elif angle < 0:
		
		frame = 1
		offset = Vector2(0, -9)
		
	elif .5 > angle and angle > 0:
		
		frame = 2
		offset = Vector2(1, -9)
		
	elif angle > 0:
		
		frame = 3
		offset = Vector2(2, -8)
