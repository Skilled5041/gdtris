extends Button


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _input(event):
	if event is InputEventKey && button_pressed:
		GameConfig.change_setting("controls", "soft_drop", event.keycode)
		button_pressed = false
