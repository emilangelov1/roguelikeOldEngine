extends KinematicBody2D

var Shots = preload("res://PlayerShots.tscn")
var speed = 250
var health = 3
var timer = 0
var player = null
var timeToWait = 0.4
var playerNode = preload("res://Player.tscn")
var velocity = Vector2.ZERO


func _physics_process(delta):
	timer += delta
	if player != null and is_instance_valid(player):
		$AnimationPlayer.play("walk")
		if position.direction_to(player.position) > Vector2(0, 0):
			$Sprite.flip_h = true
		else: 
			$Sprite.flip_h = false
		velocity = position.direction_to(player.position) * speed
	else:
		$AnimationPlayer.seek(0, true)
		$AnimationPlayer.stop(true)
		velocity = Vector2.ZERO
		
	move_and_slide(velocity)


func enemyHealthSystem():
	health -= playerNode.instance().shotDamage
	if health >= 1:
		$Sprite.visible = false
		yield(get_tree().create_timer(0.1), 'timeout')
		$Sprite.visible = true
		yield(get_tree().create_timer(0.1), 'timeout')
		$Sprite.visible = false
		yield(get_tree().create_timer(0.1), 'timeout')
		$Sprite.visible = true
		yield(get_tree().create_timer(0.1), 'timeout')
		$Sprite.visible = false
		yield(get_tree().create_timer(0.1), 'timeout')
		$Sprite.visible = true
	if health < 1:
		$CollisionShape2D.disabled = true
		health = 0
		speed = 0
		var tween = get_node("Tween")
		tween.interpolate_property(self, 'scale', Vector2(0.8, 0.8), Vector2(0, 0), 0.3, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
		tween.start()
		yield(tween, 'tween_completed')
		self.queue_free()

func _on_Area2D__Detection_body_entered(body):
	if body != self && body.is_in_group('player'):
		player = body


func _on_Area2D__Detection_body_exited(body):
	player = null
	$AnimationPlayer.seek(0, true)
	$AnimationPlayer.stop(true)


func _on_Area2D__DamageCol_body_entered(body):
	if body.is_in_group('player'):
		body.healthSystem()

