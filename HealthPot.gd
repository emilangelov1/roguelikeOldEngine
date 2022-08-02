extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var tween = Tween.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(tween)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		body.healthPickupFunc()
		tween.interpolate_property(self, 'scale', Vector2(0.7, 0.7), Vector2(0, 0), 0.3, Tween.EASE_IN_OUT)
		tween.start()
		yield(tween, "tween_completed")
		self.queue_free()
