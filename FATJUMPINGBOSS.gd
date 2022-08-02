extends KinematicBody2D


var Shots: PackedScene = preload("res://EnemyShots.tscn")
var bossDeath: PackedScene = preload("res://BossDeath.tscn")
var bossDebris: PackedScene = preload("res://FATBOSSDEBRIS.tscn")
onready var player: Node2D = null
onready var health: int = 150
onready var maxHealth: int = 150
onready var playerNode: PackedScene = preload("res://Player.tscn")
var canTeleport: bool = true
onready var tween = get_node("Tween")
onready var jumpTimer: Timer = get_node("JumpTimer")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
enum {
	jump,
	attack,
	shoot
}
var debrisAmount: int = 10
var velocity := Vector2.ZERO
var speed: int = 250
var attackState = 1

signal damageTaken
signal initialHealth
signal death

# Called when the node enters the scene tree for the first time.
func _ready():
	yield(get_tree(), 'idle_frame')
	emit_signal('initialHealth', maxHealth, health)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if attackState == 1:
		canTeleport = false
		chase()
		move_and_slide(velocity)


func _on_StateTimer_timeout() -> void:
	attackState = floor(rand_range(1, 3))
	if health >110:
		$StateTimer.wait_time = rand_range(2, 4)
	elif health < 80 and health > 40:
		$StateTimer.wait_time = rand_range(1, 3)
	else:
		$StateTimer.wait_time = rand_range(1, 2)

func chase():
	if player != null and is_instance_valid(player):
		if health > 110:
			velocity = speed * position.direction_to(player.position)
		elif health < 80 and health > 40:
			velocity = (speed + 50) * position.direction_to(player.position)
		elif health < 40:
			velocity = (speed + 75) * position.direction_to(player.position)
	elif player == null:
		velocity = Vector2.ZERO

func teleport():
	var screenSize = get_viewport().get_visible_rect().size
	if canTeleport == true and player != null and is_instance_valid(player) and health > 50:
		if $VisibilityNotifier2D.is_on_screen() and $VisibilityNotifier2D2.is_on_screen() and $VisibilityNotifier2D3.is_on_screen() and $VisibilityNotifier2D4.is_on_screen():
			$CollisionShape2D.disabled = true
			$Polygon2D.visible = false
			$AnimationPlayer.play("jump")
			yield($AnimationPlayer, "animation_finished")
			self.set_position(Vector2(player.position))
			$AnimationPlayer.play("land")
			yield($AnimationPlayer, "animation_finished")


func lowHealthJump():
	if canTeleport == true and player != null and is_instance_valid(player) and health < 25:
		if $VisibilityNotifier2D.is_on_screen() and $VisibilityNotifier2D2.is_on_screen() and $VisibilityNotifier2D3.is_on_screen() and $VisibilityNotifier2D4.is_on_screen():
			$CollisionShape2D.disabled = true
			$Polygon2D.visible = false
			$AnimationPlayer.play("jump")
			$AnimationPlayer.playback_speed = 1.8
			yield($AnimationPlayer, "animation_finished")
			self.set_position(Vector2(player.position))
			$AnimationPlayer.play("land")
			$AnimationPlayer.playback_speed = 1.8
			yield($AnimationPlayer, "animation_finished")

func midHealthJump():
	if canTeleport == true and player != null and is_instance_valid(player) and health < 50 and health > 25:
		if $VisibilityNotifier2D.is_on_screen() and $VisibilityNotifier2D2.is_on_screen() and $VisibilityNotifier2D3.is_on_screen() and $VisibilityNotifier2D4.is_on_screen():
			$CollisionShape2D.disabled = true
			$Polygon2D.visible = false
			$AnimationPlayer.play("jump")
			$AnimationPlayer.playback_speed = 1.5
			yield($AnimationPlayer, "animation_finished")
			self.set_position(Vector2(player.position))
			$AnimationPlayer.play("land")
			$AnimationPlayer.playback_speed = 1.5
			yield($AnimationPlayer, "animation_finished")


func randomDebris() -> void:
	yield($AnimationPlayer, "animation_finished")
	yield(get_tree().create_timer(1), "timeout")
	var screenSize = get_viewport().get_visible_rect().size
	for i in debrisAmount:
				debrisAmount -= 1
				var debrisInstance = bossDebris.instance()
				get_parent().add_child(debrisInstance)
				debrisInstance.set_global_position(Vector2(rand_range(0, 1920), rand_range(0, 1080)))

func _on_JumpTimer_timeout() -> void:
	jumpTimer.wait_time = floor(rand_range(2, 4))
	if health < 50:
		debrisAmount = 15
		jumpTimer.wait_time = floor(rand_range(2, 3))
	elif health < 25:
		debrisAmount = 25
		jumpTimer.wait_time = 2
	if attackState == 2:
		canTeleport = true
		if health > 50:
			teleport()
			yield(get_tree().create_timer(0.5),"timeout")
			randomDebris()
			yield(get_node("JumpTimer"), "timeout")
		elif health < 50 and health > 25:
			midHealthJump()
			yield(get_tree().create_timer(0.5),"timeout")
			randomDebris()
			yield(get_node("JumpTimer"), 'timeout')
		else:
			lowHealthJump()
			yield(get_tree().create_timer(0.5),"timeout")
			randomDebris()
			yield(get_node("JumpTimer"), 'timeout')


func shoot():
	pass


func _on_Area2D__Detection_body_entered(body):
	if body != self && body.is_in_group('player'):
		player = body



func _on_Area2D__Damage_body_entered(body):
	if body.is_in_group('player'):
		body.healthSystem()
		


func enemyHealthSystem():
	health -= playerNode.instance().shotDamage
	emit_signal("damageTaken", health, maxHealth)
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
		velocity = Vector2.ZERO
		speed = 0
		health = 0
		var tween = get_node("Tween")
		tween.interpolate_property($Sprite, 'scale', Vector2(1, 1), Vector2(0, 0), 0.3, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
		tween.start()
		var deathParticles = bossDeath.instance()
		owner.add_child(deathParticles)
		deathParticles.global_position = self.global_position
		self.queue_free()


func _on_VisibilityNotifier2D_viewport_exited(viewport):
	canTeleport = true
	var screenSize = get_viewport().get_visible_rect().size
	self.set_position(Vector2(screenSize.x/rand_range(2, 3), screenSize.y/rand_range(2, 3)))


func _on_VisibilityNotifier2D2_viewport_exited(viewport):
	canTeleport = true
	var screenSize = get_viewport().get_visible_rect().size
	self.set_position(Vector2(screenSize.x/rand_range(2, 3), screenSize.y/rand_range(2, 3)))


func _on_VisibilityNotifier2D3_viewport_exited(viewport):
	canTeleport = true
	var screenSize = get_viewport().get_visible_rect().size
	self.set_position(Vector2(screenSize.x/rand_range(2, 3), screenSize.y/rand_range(2, 3)))


func _on_VisibilityNotifier2D4_viewport_exited(viewport):
	canTeleport = true
	var screenSize = get_viewport().get_visible_rect().size
	self.set_position(Vector2(screenSize.x/rand_range(2, 3), screenSize.y/rand_range(2, 3)))


func _on_VisibilityNotifierDeath_screen_exited() -> void:
	emit_signal("death")
