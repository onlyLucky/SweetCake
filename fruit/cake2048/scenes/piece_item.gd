extends Node2D
class_name PieceItem

@onready var cell_txt: Label = $Cell/CellTxt
@onready var cell_con: PanelContainer = $Cell

# 单位变量
const POS_UNIT: int = 232
# 颜色
const CELL_BG = ["#eee4da","#ede0c8","#f2b179","#f59563","#f67c5f","#f65e3b","#edcf72","#edcc61","#99cc00","#33b5e5","#0099cc"]
#const CELL_FColor = ["#786e64","#ffffff"]

# CellTxt label 值
var cell_num: int = 2
# CellTxt label 定位信息
var cell_pos: Vector2 = Vector2(0,0)

func _ready() -> void:
	print("load item",cell_num)
	render_cell_dom()

func set_cell_value(pos: Vector2, val:int) -> void:
	cell_pos = pos*POS_UNIT
	cell_num = val

func set_text(val:int) -> void:
	cell_num = val
	cell_txt.text
	cell_txt.text = str(cell_num)
	# 更新style
	var cell_style_box = cell_con.get_theme_stylebox("panel").duplicate()  # 复制当前样式避免影响其他节点
	var color_index = get_power(2, val) - 1
	var color_value = CELL_BG[CELL_BG.size()-1]
	if CELL_BG[color_index]:
		color_value = CELL_BG[color_index]
	print(color_index, color_value)
	cell_style_box.bg_color = Color(color_value)
	# 应用修改后的样式
	cell_con.add_theme_stylebox_override("panel", cell_style_box)
	# 修复文字颜色
	if val > 4:
		var current_color = cell_txt.get_theme_color("font_color")
		cell_txt.add_theme_color_override("font_color", Color("#ffffff"))

func render_cell_dom():
	cell_txt.text = str(cell_num)
	self.position = cell_pos

func move_pos(pos: Vector2, isFree: bool = false):
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)  # 设置过渡类型
	tween.set_ease(Tween.EASE_IN_OUT)  # 设置缓动效果
	tween.tween_property(self, "position", pos*POS_UNIT, 0.2)  # 1秒移动到(300,200)
	if isFree:
		tween.tween_callback(self.queue_free)

# 计算 base 是 exponent 的几次方
func get_power(base: float, target: float) -> float:
	return log(target) / log(base)
	
	
	
