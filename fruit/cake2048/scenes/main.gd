extends Node2D

const PIECE_ITEM = preload("res://scenes/PieceItem.tscn")

@onready var piece_con: Control = $MainCon/BG/ChessBox/ChessBorad/ChessBoardMargin/PieceCon

func _ready() -> void:
	print("main ready")
	render_chess()
	
func render_chess():
	print("render_chess")
	var piece_ins = PIECE_ITEM.instantiate()
	piece_ins.cell_num = 4
	piece_ins.position = Vector2(232,0)
	piece_con.add_child(piece_ins)
