extends CodeEdit

var variables = {}

func _process(delta: float) -> void:
	var code = text.split("\n")
