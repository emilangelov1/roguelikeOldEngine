extends KinematicBody2D

var Shots: PackedScene = preload("res://PlayerShots.tscn")
#var HealthBar = preload("res://healthBar.tscn")
#var healthPickupLoad = preload("res://healthPickup.tscn")
#var playerHealth = HealthBar.instantiate()
#var healthPickup = healthPickupLoad.instantiate()
var slowTimer: PackedScene = preload("res://SlowTimeBar.tscn")
var slowTimerInstance = slowTimer.instance()
var slowTimerBar: PackedScene = preload("res://SlowTimeBar.tscn")

var speed: int = 350
var health: int = 6
var maxHealth: int = 6
var shotDamage: int = 5
var timer: float = 0
var timeToWait: float = 0.4
var canDodge: bool = true
var motion = Vector2.ZERO
var canSlowTime: bool = true
var rollSpeed: int = 700
var canTakeDamage: bool = true


signal onSlowtimeEnd
signal slowtimeStart
signal health
signal healthChange
signal healthPickup

func _ready():
	emit_signal('health', health, maxHealth)

func _physics_process(delta):
	timer += delta
	movement()
	move_and_slide(motion)

func shootRight():
	var shooting = Shots.instance()
	get_parent().add_child(shooting)
	shooting.set_direction(transform.x)
	shooting.global_position = $Position2D.global_position

func shootLeft():
	var shooting = Shots.instance()
	shooting.set_direction(transform.x.rotated(3.14))
	shooting.get_node('ShotSprite2D').rotate(3.14)
	get_parent().add_child(shooting)
	shooting.global_position = $Position2D.global_position
	
func shootUp():
	var shooting = Shots.instance()
	get_parent().add_child(shooting)
	shooting.set_direction(transform.y)
	shooting.get_node('ShotSprite2D').rotate(1.57)
	shooting.global_position = $Position2D.global_position

func shootDown():
		var shooting = Shots.instance()
		get_parent().add_child(shooting)
		shooting.set_direction(transform.y.rotated(3.14))
		shooting.get_node('ShotSprite2D').rotate(-1.57)
		shooting.global_position = $Position2D.global_position

func slowTime(speed):
	var engineTween = get_node('Tween')
	if canSlowTime:
		canSlowTime = false
		emit_signal("slowtimeStart")
		engineTween.interpolate_property(Engine, 'time_scale', 1, 0.5, 0.5, Tween.TRANS_BOUNCE, Tween.EASE_IN_OUT, 0)
		engineTween.start()
		yield(engineTween, 'tween_completed')
		yield(get_tree().create_timer(1), 'timeout')
		engineTween.interpolate_property(Engine, 'time_scale', 0.5, 1, 0.5, Tween.TRANS_BOUNCE, Tween.EASE_IN_OUT, 0)
		engineTween.start()
		yield(engineTween, 'tween_completed')
		emit_signal("onSlowtimeEnd")


func dodgeRoll():
	self.remove_from_group('player')
	canTakeDamage = false
	var tween = get_node("Tween")
	$AnimationPlayer.seek(0, true)
	$AnimationPlayer.stop()
	tween.interpolate_property($Sprite, 'rotation_degrees', 0, 360, 0.6, Tween.TRANS_BACK, Tween.EASE_IN_OUT)
	tween.interpolate_property(self, 'speed', speed, rollSpeed, 0.2, Tween.TRANS_ELASTIC, Tween.EASE_IN_OUT, 0)
	tween.start()
	tween.start()
	tween.interpolate_property(self, 'speed', rollSpeed, speed, 0.5, Tween.TRANS_ELASTIC, Tween.EASE_IN_OUT, 0.2)
	tween.start()
	yield(tween, 'tween_completed')
	yield(get_tree().create_timer(0.3), 'timeout')
	self.add_to_group('player')
	canTakeDamage = true

func movement():
	var slowTime = Input.is_action_just_pressed('slow_time')
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var shooting_x = Input.get_axis("shoot_left", "shoot_right")
	var shooting_y = Input.get_axis("shoot_up", "shoot_down")
	var dodge = Input.is_action_just_pressed('dodge_roll')
	var tween = get_node("Tween")
	motion = direction * speed
	if(slowTime):
		slowTime(speed)
	if(direction):
		$AnimationPlayer.play('walk_anim')
	else:
		$AnimationPlayer.seek(0, true)
		$AnimationPlayer.stop()
	if(direction < Vector2(0,0)):
		$Sprite.flip_h = true
	elif(direction > Vector2(0,0)):
		$Sprite.flip_h = false
	if (shooting_x > 0):
		if timer > timeToWait:
			timer = 0
			shootRight()
	elif(shooting_x < 0):
		if timer > timeToWait:
			timer = 0
			shootLeft()
	if (shooting_y > 0):
		if timer > timeToWait:
			timer = 0
			shootUp()
	elif(shooting_y < 0):
		if timer > timeToWait:
			timer = 0
			shootDown()
	if(dodge and canDodge and direction != Vector2(0, 0)):
		if health >= 1:
			canDodge = false
			yield(dodgeRoll(), 'completed')
			yield(get_tree().create_timer(0.1), 'timeout')
			canDodge = true

func healthPickupFunc():
	if health < maxHealth:
		health += 1
		emit_signal('healthPickup', health, maxHealth)

func healthSystem():
	if canTakeDamage:
		health -= 1
		emit_signal("healthChange", health, maxHealth)
		canTakeDamage = false
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
		if health == 0:
			speed = 0
			$CollisionShape2D.disabled = true
			health = 0
			var tween = get_node("Tween")
			tween.interpolate_property(self, 'rotation', 0, 1.1, 1.1, Tween.TRANS_ELASTIC, Tween.EASE_IN_OUT)
			tween.start()
			yield(get_tree().create_timer(1.1), 'timeout')
			self.queue_free()
