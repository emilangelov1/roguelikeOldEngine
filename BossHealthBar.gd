extends Control


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
onready var jumpBoss: Node2D = get_parent().get_parent().get_node("FATJUMPINGBOSS")
onready var tween: Tween = Tween.new()
onready var player := preload("res://Player.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	yield(get_tree(),"idle_frame")
	if is_instance_valid(jumpBoss):
		jumpBoss.connect('damageTaken', self, '_on_damageTaken')
		jumpBoss.connect('initialHealth', self, '_on_initialHealth')
		add_child(tween)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func _on_initialHealth(maxHealth, health):
	$ProgressBar.max_value = maxHealth
	$ProgressBar.value = health

func _on_damageTaken(health, maxHealth):
	tween.interpolate_property($ProgressBar, 'value', health, health - player.instance().shotDamage, 0.2, Tween.TRANS_EXPO)
	tween.start()
