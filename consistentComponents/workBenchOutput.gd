extends Area2D

const MECHANISM = preload("res://consistentComponents/machinesAndTBs/mechanism.tscn")

var mouseIn = false

@onready var root = get_node("/root/Game")

func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("click") and mouseIn:
		var mech = MECHANISM.instantiate()
		mech._construct(get_parent().currentBlueprint)
		mech.position = get_parent().position
		root.add_child(mech)

func _on_mouse_entered() -> void:
	mouseIn = true

func _on_mouse_exited() -> void:
	mouseIn = false
