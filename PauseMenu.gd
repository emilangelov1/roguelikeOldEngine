extends Control

var is_paused = false

func _on_Resume_pressed():
	is_paused = false

func pause():
	get_tree().paused = is_paused
	self.visible = is_paused
	var pause = Input.is_action_just_pressed('pause_menu')
	if pause:
		is_paused = !is_paused
		print(pause)

func _on_Exit_pressed():
	get_tree().quit()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pause()

