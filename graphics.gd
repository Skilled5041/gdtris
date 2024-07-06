extends Node2D

var game: Game
# Called when the node enters the scene tree for the first time.
func _ready():
	game = Game.new()
	game.spawn_new_piece_from_bag()
	game.game_started = true

var time_elapsed = 0
var last_das_time = -1
var last_arr_time = -1
var last_sdf_time = -1
var last_gravity_time = -1

var direction_held_first = ""

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time_elapsed += delta

	# If piece can't moving down start lock timer
	if (game.try_to_move_piece(Game.MoveDirections.DOWN).is_empty()):
		if (game.drop_lock_time_begin == -1):
			game.drop_lock_time_begin = time_elapsed
		elif (time_elapsed - game.drop_lock_time_begin > game.DROP_LOCK_DELAY / 1000.0):
			game.hard_drop()
			queue_redraw()
	else:
		game.drop_lock_time_begin = -1

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

	if Input.is_action_pressed("move_left") && direction_held_first == "":
		direction_held_first = "left"
		handle_left_das()
	elif Input.is_action_pressed("move_right") && direction_held_first == "":
		direction_held_first = "right"
		handle_right_das()
	
	if (direction_held_first == "left"):
		handle_left_das()
		handle_right_das()
	elif (direction_held_first == "right"):
		handle_right_das()
		handle_left_das()

	if Input.is_action_pressed("soft_drop"):
		if (last_sdf_time != - 1 and time_elapsed - last_sdf_time > game.soft_drop_factor / 1000.0):
			game.move_piece(Game.MoveDirections.DOWN)
			last_sdf_time = time_elapsed
			queue_redraw()
		elif last_sdf_time == - 1:
			last_sdf_time = time_elapsed
	else:
		last_sdf_time = -1

	if (last_gravity_time != - 1 and time_elapsed - last_gravity_time > game.gravity_fall_delay / 1000.0):
		game.move_piece(Game.MoveDirections.DOWN)
		last_gravity_time = time_elapsed
		queue_redraw()
	elif last_gravity_time == -1:
		last_gravity_time = time_elapsed

const COLORS = {
	Tile.TileType.I_PIECE: Color(0, 1, 1, 1),
	Tile.TileType.J_PIECE: Color(0, 0, 1, 1),
	Tile.TileType.L_PIECE: Color(1, 0.5, 0, 1),
	Tile.TileType.O_PIECE: Color(1, 1, 0, 1),
	Tile.TileType.S_PIECE: Color(0, 1, 0, 1),
	Tile.TileType.T_PIECE: Color(1, 0, 1, 1),
	Tile.TileType.Z_PIECE: Color(1, 0, 0, 1),
	Tile.TileType.GHOST: Color(0, 0, 0, 0.5),
	Tile.TileType.EMPTY: Color(0, 0, 0, 1),
	Tile.TileType.DISABLED: Color(0.5, 0.5, 0.5, 1)
}

# TODO: get screen size and scale the game board accordingly
func _draw():
		# Draw board
		for i in range(0, 10):
			for j in range(0, 24):
				draw_rect(Rect2(i * 15 + 400, j * 15 + 200, 14, 14), COLORS[game.board[i][j].type])

		if (game.hold_piece != null):
			# Draw hold piece
			for i in range(game.hold_piece.tiles.size()):
				for j in range(game.hold_piece.tiles[i].size()):
					if game.hold_piece.tiles[i][j].type != Tile.TileType.EMPTY:
						if (game.already_held):
							draw_rect(Rect2(j * 15 + 300, i * 15 + 200, 14, 14), Color(0.5, 0.5, 0.5, 1))
						else:
							draw_rect(Rect2(j * 15 + 300, i * 15 + 200, 14, 14), COLORS[game.hold_piece.tiles[i][j].type])

		# Queue
		for i in range(game.piece_queue.size()):
			for j in range(game.piece_queue[i].tiles.size()):
				for k in range(game.piece_queue[i].tiles[j].size()):
					if game.piece_queue[i].tiles[j][k].type != Tile.TileType.EMPTY:
						draw_rect(Rect2(k * 15 + 600, j * 15 + 200 + i * 60, 14, 14), COLORS[game.piece_queue[i].tiles[j][k].type])


func handle_left_das():
	if Input.is_action_pressed("move_left"):
		if (last_das_time != - 1 and time_elapsed - last_das_time > game.delayed_auto_shift / 1000.0):
			if game.auto_repeat_rate == 0:
				for i in range(0, 10):
					game.move_piece(Game.MoveDirections.LEFT)
			else:
				if (last_arr_time != - 1 and time_elapsed - last_arr_time > game.auto_repeat_rate / 1000.0):
					game.move_piece(Game.MoveDirections.LEFT)
					last_arr_time = time_elapsed - (time_elapsed - last_arr_time - game.auto_repeat_rate / 1000.0)
			queue_redraw()
		elif last_das_time == - 1:
			last_das_time = time_elapsed
		if last_arr_time == - 1:
			last_arr_time = time_elapsed
	elif not Input.is_action_pressed("move_right"):
		last_das_time = -1
		last_arr_time = -1
		direction_held_first = ""

func handle_right_das():
	if Input.is_action_pressed("move_right"):
		if (last_das_time != - 1 and time_elapsed - last_das_time > game.delayed_auto_shift / 1000.0):
			if game.auto_repeat_rate == 0:
				for i in range(0, 10):
					game.move_piece(Game.MoveDirections.RIGHT)
			else:
				if (last_arr_time != - 1 and time_elapsed - last_arr_time > game.auto_repeat_rate / 1000.0):
					game.move_piece(Game.MoveDirections.RIGHT)
					last_arr_time = time_elapsed - (time_elapsed - last_arr_time - game.auto_repeat_rate / 1000.0)
			queue_redraw()
		elif last_das_time == - 1:
			last_das_time = time_elapsed
		if last_arr_time == - 1:
			last_arr_time = time_elapsed
	elif not Input.is_action_pressed("move_left"):
		last_das_time = -1
		last_arr_time = -1
		direction_held_first = ""
