extends TileMap

const SIZE = .9

func _ready():
	scale = Vector2(SIZE, SIZE)

func _process(delta):
	position = get_node("../Player").position * ( 1 - SIZE)
