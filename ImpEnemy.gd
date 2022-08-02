extends KinematicBody2D


var Shots: PackedScene = preload("res://EnemyShots.tscn")
onready var rayCast: RayCast2D = $RayCast2D
onready var player = null
onready var health: int = 5
onready var playerNode: PackedScene = preload("res://Player.tscn")
var canTeleport: bool = true

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	yield(get_tree(), 'idle_frame')


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player != null and is_instance_valid(player):
		if position.direction_to(player.position) > Vector2(0, 0):
			$Sprite.flip_h = true
		else: 
			$Sprite.flip_h = false
		var angle_to_target = global_position.direction_to(player.global_position).angle()
		rayCast.global_rotation = angle_to_target
		if rayCast.is_colliding() and rayCast.get_collider().is_in_group('player'):
			Shots.instance().rotation = angle_to_target
			shoot()

func teleport():
	if canTeleport:
		yield(get_tree().create_timer(rand_range(3, 6)), 'timeout')
		$CPUParticles2D.emitting = true
		yield(get_tree().create_timer(0.2), 'timeout')
		$CPUParticles2D.emitting = false
		var screenSize = get_viewport().get_visible_rect().size
		if $VisibilityNotifier2D.is_on_screen() and $VisibilityNotifier2D2.is_on_screen() and $VisibilityNotifier2D3.is_on_screen() and $VisibilityNotifier2D4.is_on_screen():
			self.set_position(Vector2(
				rand_range(-screenSize.x/rand_range(2, 4),
				 screenSize.x/rand_range(2, 4)),
				 rand_range(-screenSize.y/rand_range(6, 8),
				 screenSize.y/rand_range(6, 8))))
		canTeleport = false
	yield(get_tree().create_timer(rand_range(2, 4)), 'timeout')
	canTeleport = true
	

func shoot():
	rayCast.enabled = false
	var shotsInstance: Node2D = Shots.instance()
	get_tree().current_scene.add_child(shotsInstance)
	shotsInstance.global_position = $Position2D.global_position
	shotsInstance.global_rotation = rayCast.global_rotation
	yield(get_tree().create_timer(rand_range(0.2, 1)), "timeout")
	rayCast.enabled = true


func _on_Area2D__Detection_body_entered(body):
	if body != self && body.is_in_group('player'):
		player = body
		teleport()


func _on_Area2D__Damage_body_entered(body):
	if body.is_in_group('player'):
		body.healthSystem()


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
		var tween = get_node("Tween")
		tween.interpolate_property(self, 'scale', Vector2(0.8, 0.8), Vector2(0, 0), 0.3, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
		tween.start()
		yield(tween, 'tween_completed')
		self.queue_free()


func _on_Area2D__Detection_body_exited(body):
	if body.is_in_group('player'):
		canTeleport = false


func _on_VisibilityNotifier2D_screen_exited():
	var screenSize = get_viewport().get_visible_rect().size
	self.set_position(Vector2(screenSize.x/rand_range(2, 4), screenSize.y/rand_range(2, 4)))
