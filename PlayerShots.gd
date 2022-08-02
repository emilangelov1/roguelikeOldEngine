extends Area2D

const projectileSpeed = 850

var dir = Vector2.ZERO

func set_direction(dir: Vector2):
	self.dir = dir

func _process(delta):
	position += dir * projectileSpeed * delta
	#print(dir)

func _on_shots_body_entered(body):
	if body.is_in_group('enemy'):
		body.enemyHealthSystem()
		queue_free()
