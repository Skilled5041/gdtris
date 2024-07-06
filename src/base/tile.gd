extends Node

class_name Tile

enum TileType {
	I_PIECE,
	J_PIECE,
	L_PIECE,
	O_PIECE,
	S_PIECE,
	T_PIECE,
	Z_PIECE,
	GHOST,
	GARBAGE,
	DISABLED,
	EMPTY,
}

enum State {
	EMPTY,
	PLACED,
	FALLING
}


var type: TileType
var state: State

func _init(tile_type: TileType, tile_state: State):
	type = tile_type
	state = tile_state
