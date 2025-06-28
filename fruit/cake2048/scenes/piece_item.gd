extends Node2D
class_name PieceItem

var cell_num: int = 2

func _ready() -> void:
	print("load item",cell_num)

static func constructor(value: int=2)-> void:
	print("constructor value",value)
