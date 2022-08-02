extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var tween = Tween.new()

onready var player = get_parent().get_parent().get_node('Player')

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(tween)
	player.connect('onSlowtimeEnd', self, 'onSlowtimeEnd')
	player.connect('slowtimeStart', self, 'onSlowtimeStart')
	$ProgressBar.value = 100


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func onSlowtimeStart():
	tween.interpolate_property($ProgressBar, 'value', 100, 0, 0.5, Tween.TRANS_EXPO, Tween.EASE_IN_OUT, 0)
	tween.start()

func onSlowtimeEnd():
	tween.interpolate_property($ProgressBar, 'value', 0, 100, 8, Tween.EASE_OUT, 0)
	tween.start()
	yield(tween, 'tween_completed')
	player.canSlowTime = true


#func _on_ProgressBarTimer_timeout():
