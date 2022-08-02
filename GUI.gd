extends CanvasLayer


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
onready var jumpBoss = get_parent().get_node('FATJUMPINGBOSS')


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$BossHealthBar.visible = false
	yield(get_tree(), "idle_frame")
	if is_instance_valid(jumpBoss):
		jumpBoss.connect('death', self, '_on_death')
		$BossHealthBar.visible = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func _on_death() -> void:
	if is_instance_valid(jumpBoss):
		$BossHealthBar.visible = false
