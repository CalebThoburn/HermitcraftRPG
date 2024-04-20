extends Area2D

var info

func _on_body_entered(body):
	
	if body.CREATURE == "Player":
		body.antennaInRange.append(self)

func _on_body_exited(body):
	if body.CREATURE == "Player":
		body.antennaInRange.erase(self)

func _power():
	var connection = get_parent().blueprint[info["position"].x][info["position"].y]["connectedTo"]
	get_parent().blueprint[connection.x][connection.y]["powered"] = true
