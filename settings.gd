extends Node

func _input(event):
	if event.is_action_pressed("settings"):
		get_tree().change_scene_to_file("res://game.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass 

