extends Area2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	debrisSpawn()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass


func debrisSpawn() -> void:
	$AnimationPlayer.play("debrisSpawn")
	yield($AnimationPlayer, "animation_finished")
	self.queue_free()


func _on_Area2D_body_entered(body: Node) -> void:
	if body.is_in_group('player'):
		body.healthSystem()
