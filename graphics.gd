extends Node2D


var game: Game
# Called when the node enters the scene tree for the first time.
func _ready():
	game = Game.new()
	game.spawn_new_piece_from_bag()
	game.game_started = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# If space is pressed, hard drop the piece
	if Input.is_action_just_pressed("hard_drop"):
		game.hard_drop()
		queue_redraw()
	elif Input.is_action_just_pressed("move_left"):
		game.move_piece(Game.MoveDirections.LEFT)
		queue_redraw()
	elif Input.is_action_just_pressed("move_right"):
		game.move_piece(Game.MoveDirections.RIGHT)
		queue_redraw()
	elif Input.is_action_just_pressed("soft_drop"):
		game.move_piece(Game.MoveDirections.DOWN)
		queue_redraw()
	elif Input.is_action_just_pressed("rotate_cw"):
		game.rotate_piece(Piece.RotationAmount.NINETY_DEGREES)
		queue_redraw()
	elif Input.is_action_just_pressed("rotate_ccw"):
		game.rotate_piece(Piece.RotationAmount.TWO_HUNDRED_SEVENTY_DEGREES)
		queue_redraw()
	elif Input.is_action_just_pressed("rotate_180"):
		game.rotate_piece(Piece.RotationAmount.ONE_HUNDRED_EIGHTY_DEGREES)
		queue_redraw()
	elif Input.is_action_just_pressed("hold"):
		game.hold()
		queue_redraw()
		

func _draw():
		for i in range(0, 10):
			for j in range(0, 24):
				var color: Color
				if game.board[i][j].type == Tile.TileType.EMPTY:
					color = Color(0, 0, 0, 1)
				elif game.board[i][j].type == Tile.TileType.I_PIECE:
					color = Color(0, 1, 1, 1)
				elif game.board[i][j].type == Tile.TileType.J_PIECE:
					color = Color(0, 0, 1, 1)
				elif game.board[i][j].type == Tile.TileType.L_PIECE:
					color = Color(1, 0.5, 0, 1)
				elif game.board[i][j].type == Tile.TileType.O_PIECE:
					color = Color(1, 1, 0, 1)
				elif game.board[i][j].type == Tile.TileType.S_PIECE:
					color = Color(0, 1, 0, 1)
				elif game.board[i][j].type == Tile.TileType.T_PIECE:
					color = Color(1, 0, 1, 1)
				elif game.board[i][j].type == Tile.TileType.Z_PIECE:
					color = Color(1, 0, 0, 1)
				elif game.board[i][j].type == Tile.TileType.GHOST:
					color = Color(0, 0, 0, 0.5)
				elif game.board[i][j].type == Tile.TileType.DISABLED:
					color = Color(0.5, 0.5, 0.5, 1)
				draw_rect(Rect2(i * 15, j * 15, 14, 14), color)	
