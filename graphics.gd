extends Node2D

var game: Game
# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().get_root().size_changed.connect(on_window_resize) 
	window_size = get_viewport_rect().size
	window_center = window_size / 2
	tile_size = window_size.y / 30
	grid_start = Vector2(window_center.x - 5 * tile_size - tile_size / 2, window_center.y - 12 * tile_size - tile_size / 2)

	game = Game.new()
	game.spawn_new_piece_from_bag()
	game.game_started = true

var time_elapsed = 0
var last_das_time = -1
var last_arr_time = -1
var last_sdf_time = -1
var last_gravity_time = -1

var direction_held_first = ""

func _input(event):	
	if event.is_action_pressed("open_settings"):
		get_tree().change_scene_to_file("res://settings.tscn")
	
	# If space is pressed, hard drop the piece
	if event.is_action_pressed("hard_drop"):
		game.hard_drop()
		queue_redraw()
	elif event.is_action_pressed("move_left"):
		game.move_piece(Game.MoveDirections.LEFT)
		queue_redraw()
	elif event.is_action_pressed("move_right"):
		game.move_piece(Game.MoveDirections.RIGHT)
		queue_redraw()
	elif event.is_action_pressed("soft_drop"):
		if (game.soft_drop_factor == 0):
			for i in range(0, 20):
				game.move_piece(Game.MoveDirections.DOWN)
		game.move_piece(Game.MoveDirections.DOWN)
		queue_redraw()
	elif event.is_action_pressed("rotate_cw"):
		game.rotate_piece(Piece.RotationAmount.NINETY_DEGREES)
		queue_redraw()
	elif event.is_action_pressed("rotate_ccw"):
		game.rotate_piece(Piece.RotationAmount.TWO_HUNDRED_SEVENTY_DEGREES)
		queue_redraw()
	elif event.is_action_pressed("rotate_180"):
		game.rotate_piece(Piece.RotationAmount.ONE_HUNDRED_EIGHTY_DEGREES)
		queue_redraw()
	elif event.is_action_pressed("hold"):
		game.hold()
		queue_redraw()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time_elapsed += delta

	# If piece can't moving down start lock timer
	if (game.try_to_move_piece(Game.MoveDirections.DOWN).is_empty()):
		if (game.drop_lock_time_begin == -1):
			game.drop_lock_time_begin = time_elapsed
		elif (time_elapsed - game.drop_lock_time_begin > game.DROP_LOCK_DELAY / 1000.0):
			game.hard_drop()
			game.drop_lock_reset_count = 0
			queue_redraw()
	else:
		game.drop_lock_time_begin = -1

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
	Tile.TileType.GHOST: Color(1, 1, 1, 0.2),
	Tile.TileType.EMPTY: Color(0, 0, 0, 0),
	Tile.TileType.DISABLED: Color(0.5, 0.5, 0.5, 1)
}

var window_size
var window_center
var tile_size
var grid_start

func on_window_resize():
	window_size = get_viewport_rect().size
	window_center = window_size / 2
	tile_size = window_size.y / 30
	grid_start = Vector2(window_center.x - 5 * tile_size - tile_size / 2, window_center.y - 12 * tile_size - tile_size / 2)
	queue_redraw()

@onready var tile_map: TileMap = $"../TileMap"
@onready var tile_map_texture: Texture2D = tile_map.tile_set.get_source(0).texture

func draw_tile(tile: Tile.TileType, x: int, y: int):
	if (tile == Tile.TileType.EMPTY):
		return

	var atlas_coord: int = int(tile)

	var src_region = tile_map.tile_set.get_source(0).get_tile_texture_region(Vector2i(0, 0), 0)
	var dest_region = tile_map.tile_set.get_source(0).get_tile_texture_region(Vector2i(atlas_coord, 0), 0)

	src_region.size.x *= float(tile_size / src_region.size.x)
	src_region.size.y *= float(tile_size / src_region.size.y)
	src_region.position.x = x
	src_region.position.y = y

	if (tile == Tile.TileType.GHOST):
		draw_texture_rect_region(tile_map_texture, src_region, dest_region, Color(1, 1, 1, 0.2))
	else:
		draw_texture_rect_region(tile_map_texture, src_region, dest_region)

var hud_font: Font = load("res://assets/JetBrainsMono-SemiBold.ttf")

func _draw():
	if (game.game_started):
		# Draw grid background
		draw_rect(Rect2(grid_start.x, grid_start.y + 4 * tile_size, 10 * tile_size, 20 * tile_size), Color(0, 0, 0, 0.5))

		# Draw grid:
		for i in range(0, 10):
			for j in range(4, 24):
				draw_rect(Rect2(i * tile_size + grid_start.x, j * tile_size + grid_start.y, tile_size, tile_size), Color(1, 1, 1, 0.1), false, 2.0)

		# Draw board
		for i in range(0, 10):
			for j in range(0, 24):
				draw_tile(game.board[i][j].type, i * tile_size + grid_start.x, j * tile_size + grid_start.y)

		# Draw Hold HUD text
		draw_string(hud_font, Vector2(grid_start.x - 1 * tile_size - hud_font.get_string_size("HOLD", HORIZONTAL_ALIGNMENT_LEFT, -1, tile_size).x, grid_start.y + 5 * tile_size), "HOLD", HORIZONTAL_ALIGNMENT_LEFT, -1, tile_size)

		if (game.hold_piece != null):
			# Draw hold piece
			for i in range(game.hold_piece.tiles.size()):
				for j in range(game.hold_piece.tiles[i].size()):
					if game.hold_piece.tiles[i][j].type != Tile.TileType.EMPTY:
						if (game.already_held):
							draw_tile(Tile.TileType.GARBAGE, j * tile_size + grid_start.x - 5 * tile_size, i * tile_size + grid_start.y + 6 * tile_size)
						else:
							draw_tile(game.hold_piece.tiles[i][j].type, j * tile_size + grid_start.x - 5 * tile_size, i * tile_size + grid_start.y + 6 * tile_size)
		
		# Draw Queue Text HUD
		draw_string(hud_font, Vector2(grid_start.x + 11 * tile_size, grid_start.y + 5 * tile_size), "QUEUE", HORIZONTAL_ALIGNMENT_LEFT, -1, tile_size)

		# Queue
		for i in range(game.piece_queue.size()):
			for j in range(game.piece_queue[i].tiles.size()):
				for k in range(game.piece_queue[i].tiles[j].size()):
					if game.piece_queue[i].tiles[j][k].type != Tile.TileType.EMPTY:
						draw_tile(game.piece_queue[i].tiles[j][k].type, k * tile_size + grid_start.x + 11 * tile_size, j * tile_size + grid_start.y + 6 * tile_size + i * 3 * tile_size)

		# Lines cleared HUD
		draw_string(hud_font, Vector2(grid_start.x - 1 * tile_size - hud_font.get_string_size("QUEUE", HORIZONTAL_ALIGNMENT_LEFT, -1, tile_size).x, grid_start.y + 20 * tile_size), "LINES", HORIZONTAL_ALIGNMENT_LEFT, -1, tile_size, Color(1, 1, 1, 1), HORIZONTAL_ALIGNMENT_RIGHT)
		draw_string(hud_font, Vector2(grid_start.x - 1 * tile_size - hud_font.get_string_size(str(game.number_of_lines_cleared), HORIZONTAL_ALIGNMENT_LEFT, -1, tile_size).x, grid_start.y + 22 * tile_size), str(game.number_of_lines_cleared), HORIZONTAL_ALIGNMENT_LEFT, -1, tile_size, Color(1, 1, 1, 1), HORIZONTAL_ALIGNMENT_RIGHT)


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
