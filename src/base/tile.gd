extends Node

class_name Tile

enum TILE_TYPE {
	I_PIECE,
	J_PIECE,
	L_PIECE,
	O_PIECE,
	S_PIECE,
	T_PIECE,
	Z_PIECE,
	GHOST,
	EMPTY,
	DISABLED
}

enum STATE {
	EMPTY,
	PLACED,
	FALLING
}


var type: TILE_TYPE
var state: STATE

func _init(tile_type: TILE_TYPE, tile_state: STATE):
	type = tile_type
	state = tile_state