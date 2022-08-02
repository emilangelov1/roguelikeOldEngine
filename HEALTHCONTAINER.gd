extends HBoxContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var player: Node2D = get_parent().get_parent().get_node('Player')
onready var heart: PackedScene = preload("res://HEALTH.tscn")
onready var emptyHeart: PackedScene = preload("res://EMPTYHEALTH.tscn")
var tween: Tween = Tween.new()



# Called when the node enters the scene tree for the first time.
func _ready():
	player.connect('health', self, '_on_health')
	player.connect('healthChange', self, '_on_healthChange')
	player.connect('healthPickup', self, "_on_healthPickup")
	add_child(tween)
	

func _on_health(health, maxHealth):
	for i in maxHealth:
		var heartsInstance = heart.instance()
		add_child(heartsInstance)
#		yield(get_tree().create_timer(1), 'timeout')

func _on_healthChange(health, maxHealth):
	var i = 0
#	print(get_children())
	if health == maxHealth and player != null and is_instance_valid(player):
		tween.interpolate_property(get_children()[i+1], 'rect_scale', Vector2(1, 1), Vector2(1.3, 1.3), 0.1, Tween.TRANS_EXPO, Tween.EASE_IN)
		tween.start()
		yield(tween, 'tween_completed')
		get_children().back().queue_free()
	while i < maxHealth:
		if i == health and player != null and is_instance_valid(player) and is_instance_valid(heart):
			tween.interpolate_property(get_children()[i+1], 'rect_scale', Vector2(1, 1), Vector2(1.1, 1.1), 0.2, Tween.TRANS_EXPO, Tween.EASE_IN)
			tween.start()
			yield(tween, 'tween_completed')
			tween.interpolate_property(get_children()[i+1], 'rect_scale', Vector2(1.3, 1.3), Vector2(0, 0), 0.3, Tween.TRANS_EXPO, Tween.EASE_IN)
			tween.start()
			yield(tween, 'tween_completed')
			get_children()[i].queue_free()
			if i < 1:
				get_children()[1].queue_free()
		i += 1
	add_child(emptyHeart.instance())
	yield(get_tree().create_timer(0.3), 'timeout')
	if player != null and is_instance_valid(player):
		player.canTakeDamage = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_healthPickup(health, maxHealth):
#	for n in get_children():
#		remove_child(n)
#	for i in health:
#		var heartsInstance = heart.instance()
#		add_child(heartsInstance)
#	print(get_children())
#	var n = 0
#	while n < maxHealth:
#		if n == health:
#			get_children().back().queue_free()
#			get_children()[n - n+1].add_child(heart.instance())
#			break
#		n += 1
#	for allHearts in get_child_count():
#		print(get_child_count())
#		get_children()[allHearts].queue_free()
#	for heartsFull in health:
#		add_child(heart.instance())
#	for emptyHearts in maxHealth - health:
#		add_child(emptyHeart.instance())
#	for n in maxHealth:
#		if n == health and player != null and is_instance_valid(player) and is_instance_valid(heart):
#			tween.interpolate_property(get_children()[n], 'rect_scale', Vector2(1, 1), Vector2(1.1, 1.1), 0.2, Tween.TRANS_EXPO, Tween.EASE_IN)
#			tween.start()
#			yield(tween, 'tween_completed')
#			tween.interpolate_property(get_children()[n], 'rect_scale', Vector2(1.3, 1.3), Vector2(0, 0), 0.3, Tween.TRANS_EXPO, Tween.EASE_IN)
#			tween.start()
#			yield(tween, 'tween_completed')
#			get_children()[n].add_child(heart.instance())
	for eachHeart in get_child_count():
		if eachHeart == health:
			tween.interpolate_property(get_children()[eachHeart], 'rect_scale', Vector2(1, 1), Vector2(1.1, 1.1), 0.2, Tween.TRANS_EXPO, Tween.EASE_IN)
			tween.start()
			yield(tween, 'tween_completed')
			tween.interpolate_property(get_children()[eachHeart], 'rect_scale', Vector2(1.3, 1.3), Vector2(0, 0), 0.3, Tween.TRANS_EXPO, Tween.EASE_IN)
			tween.start()
			yield(tween, 'tween_completed')
			add_child(heart.instance())
		if eachHeart >= health:
			print(eachHeart)
			get_children()[eachHeart].queue_free()
	for emptyHearts in maxHealth - health:
		add_child(emptyHeart.instance())
#	var n = 1
#	while n <= health:
#		if n == health:
#			print(get_children()[n-1])
#			add_child(heart.instance())
#		n += 1
