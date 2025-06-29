extends Node2D
class_name PieceItem

@onready var cell_txt: Label = $Cell/CellTxt

# 单位变量
const POS_UNIT: int = 232

# CellTxt label 值
var cell_num: int = 2
# CellTxt label 定位信息
var cell_pos: Vector2 = Vector2(0,0)

func _ready() -> void:
	print("load item",cell_num)
	render_cell_dom()

func set_txt_value(pos: Vector2, val:int) -> void:
	cell_pos = pos*POS_UNIT
	cell_num = val

func render_cell_dom():
	cell_txt.text = str(cell_num)
	self.position = cell_pos
