extends Node2D


var game_board: Board
# Called when the node enters the scene tree for the first time.
func _ready():
	game_board = Board.new()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _draw():
		for i in range(0, 10):
			for j in range(0, 20):
				draw_rect(Rect2(i * 34, j * 34, 32, 32), Color(0, 0, 0, 1))	
