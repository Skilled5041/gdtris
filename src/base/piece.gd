extends Node

class_name Piece

enum Pieces {
	I_PIECE,
	J_PIECE,
	L_PIECE,
	O_PIECE,
	S_PIECE,
	T_PIECE,
	Z_PIECE,
}

# Possible rotations for each shape
const PIECE_ARRAYS = [
	# I
	[
		[
			[0, 0, 0, 0],
			[1, 1, 1, 1],
			[0, 0, 0, 0],
			[0, 0, 0, 0]
		],
		[
			[0, 0, 1, 0],
			[0, 0, 1, 0],
			[0, 0, 1, 0],
			[0, 0, 1, 0]
		],
		[
			[0, 0, 0, 0],
			[0, 0, 0, 0],
			[1, 1, 1, 1],
			[0, 0, 0, 0]
		],
		[
			[0, 1, 0, 0],
			[0, 1, 0, 0],
			[0, 1, 0, 0],
			[0, 1, 0, 0]
		]
	],
	# J
	[
		[
			[1, 0, 0],
			[1, 1, 1],
			[0, 0, 0]
		],
		[
			[0, 1, 1],
			[0, 1, 0],
			[0, 1, 0]
		],
		[
			[0, 0, 0],
			[1, 1, 1],
			[0, 0, 1]
		],
		[
			[0, 1, 0],
			[0, 1, 0],
			[1, 1, 0]
		]
	],
	# L
	[
		[
			[0, 0, 1],
			[1, 1, 1],
			[0, 0, 0]
		],
		[
			[0, 1, 0],
			[0, 1, 0],
			[0, 1, 1]
		],
		[
			[0, 0, 0],
			[1, 1, 1],
			[1, 0, 0]
		],
		[
			[1, 1, 0],
			[0, 1, 0],
			[0, 1, 0]
		]
	],
	# O
	[
		[
			[0, 1, 1, 0],
			[0, 1, 1, 0],
			[0, 0, 0, 0]
		]
	],
	# S
	[
		[
			[0, 1, 1],
			[1, 1, 0],
			[0, 0, 0]
		],
		[
			[0, 1, 0],
			[0, 1, 1],
			[0, 0, 1]
		],
		[
			[0, 0, 0],
			[0, 1, 1],
			[1, 1, 0]
		],
		[
			[1, 0, 0],
			[1, 1, 0],
			[0, 1, 0]
		]
	],
	# T
	[
		[
			[0, 1, 0],
			[1, 1, 1],
			[0, 0, 0]
		],
		[
			[0, 1, 0],
			[0, 1, 1],
			[0, 1, 0]
		],
		[
			[0, 0, 0],
			[1, 1, 1],
			[0, 1, 0]
		],
		[
			[0, 1, 0],
			[1, 1, 0],
			[0, 1, 0]
		]
	],
	# Z
	[
		[
			[1, 1, 0],
			[0, 1, 1],
			[0, 0, 0]
		],
		[
			[0, 0, 1],
			[0, 1, 1],
			[0, 1, 0]
		],
		[
			[0, 0, 0],
			[1, 1, 0],
			[0, 1, 1]
		],
		[
			[0, 1, 0],
			[1, 1, 0],
			[1, 0, 0]
		]
	]
]

enum RotationState {
	ZERO_DEGREES,
	NINETY_DEGREES,
	ONE_HUNDRED_EIGHTY_DEGREES,
	TWO_HUNDRED_SEVENTY_DEGREES
}

const NUMBER_OF_ROTATION_STATES = [4, 4, 4, 1, 4, 4, 4]

func get_number_of_rotation_states() -> int:
	return NUMBER_OF_ROTATION_STATES[piece_type]

var piece_type: Pieces
var tile_type: Tile.TileType
var tiles: Array[Array]
var rotation: RotationState = RotationState.ZERO_DEGREES

func _init(piece: Pieces):
	piece_type = piece
	match piece:
		Pieces.I_PIECE:
			tile_type = Tile.TileType.I_PIECE
		Pieces.J_PIECE:
			tile_type = Tile.TileType.J_PIECE
		Pieces.L_PIECE:
			tile_type = Tile.TileType.L_PIECE
		Pieces.O_PIECE:
			tile_type = Tile.TileType.O_PIECE
		Pieces.S_PIECE:
			tile_type = Tile.TileType.S_PIECE
		Pieces.T_PIECE:
			tile_type = Tile.TileType.T_PIECE
		Pieces.Z_PIECE:
			tile_type = Tile.TileType.Z_PIECE

	tiles = []
	for row in PIECE_ARRAYS[piece][0]:
		tiles.append([])
		for tile in row:
			if tile == 1:
				tiles.append(Tile.new(tile_type, Tile.State.FALLING))
			else:
				tiles.append(Tile.new(Tile.TileType.EMPTY, Tile.State.EMPTY))

func set_rotation(new_rotation: RotationState):
	if rotation == new_rotation:
		return
	
	rotation = new_rotation
	for row in PIECE_ARRAYS[piece_type][rotation]:
		for tile in row:
			if tile == 1:
				tile.append(Tile.new(tile_type, Tile.State.FALLING))
			else:
				tile.append(Tile.new(Tile.TileType.EMPTY, Tile.State.EMPTY))
