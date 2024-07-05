extends Node

class_name Board

# TODO: add config options for this
var auto_repeat_rate: int = 0
var delayed_auto_shift: int = 100
var soft_drop_factor: float = 0

var soft_dropping: bool = false

enum MoveDirections {
    LEFT,
    RIGHT,
    DOWN
}

# The List of the coordinates for the non-empty squares of the current piece
# (0, 0) is the top left of the board
# (9, 23) is the bottom right of the board
var current_piece_coordinates: Array[Vector2]

var piece_queue: Array[Piece]

var current_piece: Piece

# The top left corner of the bounding box for the current piece
var current_piece_top_left_corner: Vector2

var ghost_coordinates: Array[Vector2]
var hold_piece: Piece = null
var already_held: bool = false

# Stores the highest row that contains a piece, 0 is the highest row (for performance)
var highest_piece_row: int

var bag_1: Array[Piece]
var bag_2: Array[Piece]

# Number of rows per second a piece falls
var gravity: float = 1

var number_of_lines_cleared: int = 0

# How often a piece falls in milliseconds
var gravity_fall_delay: int = int(1000 / gravity)

# Pieces locks after 0.5s on the ground
# How long the piece has been on the ground in ms
var drop_lock_time = 0
const DROP_LOCK_DELAY = 500

var game_started: bool = false
var game_ended: bool = false

# Can reset lock delay up to 15 time by moving the piece
var drop_lock_reset_count: int = 0

# Number of lines cleared in a row
var combo: int = 0

# If player is still alive
var alive = true

var board: Array[Array]

func get_piece_from_bag():
    var piece = Piece.new(bag_1.pop_front())
    bag_1.push_back(bag_2.pop_front())

    if bag_2.is_empty():
        # Add a pieces to bag 2 and shuffle
        var random_values: Array[int] = []
        for i in range(0, 7):
            random_values.push_back(i)
        random_values.shuffle()

        for value in random_values:
            bag_2.push_back(Piece.Pieces.values()[value])

    return piece

func hold():
    if already_held:
        return

    # Clear the current piece
    for point in current_piece_coordinates:
        board[point.x][point.y].state = Tile.State.EMPTY
        board[point.x][point.y].type = Tile.TileType.EMPTY

    # Clear the ghost
    for point in ghost_coordinates:
        board[point.x][point.y].state = Tile.State.EMPTY
        board[point.x][point.y].type = Tile.TileType.EMPTY

    # Hold the piece
    if hold_piece == null:
        hold_piece = Piece.new(current_piece.type)
    else:
        var temp = hold_piece
        hold_piece = Piece.new(current_piece.type)
        current_piece = temp

func spawn_new_piece_from_bag():
    piece_queue.push_back(get_piece_from_bag())
    spawn_new_piece(piece_queue.pop_front())

func spawn_new_piece(piece: Piece):
    current_piece = piece
    already_held = false

    current_piece_coordinates.clear()
    current_piece_top_left_corner = Vector2(3, 2)

    # Check if player is dead
    for i in range(0, current_piece.tiles[0].)