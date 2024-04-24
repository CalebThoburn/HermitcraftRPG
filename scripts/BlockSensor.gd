extends Area2D

var blocksTouching = -1

func _on_body_entered(body):
	print(blocksTouching)
	blocksTouching += 1


func _on_body_exited(body):
	blocksTouching -= 1
