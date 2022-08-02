extends Node2D

const RIGHT = Vector2.RIGHT
export(int) var SPEED: int = 600


func _physics_process(delta):
	var movement = RIGHT.rotated(rotation) * SPEED * delta
	global_position += movement

func destroy():
	queue_free()

func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		body.healthSystem()
		destroy()
