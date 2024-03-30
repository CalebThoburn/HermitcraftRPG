extends TileMap

@onready var size = 1 - (1 - get_node("../Background").SIZE) / 2

func _ready():
	scale = Vector2(size, size)

func _process(delta):
	position = get_node("../Player").position * ( 1 - size)
