extends Node2D

const PIECE_ITEM = preload("res://scenes/PieceItem.tscn")

@onready var piece_con: Control = $MainCon/BG/ChessBox/ChessBorad/ChessBoardMargin/PieceCon

#限制距离
var limit_value:float = 150.0
# 触摸开始位置
var touch_start_position: Vector2 = Vector2.ZERO
# 触摸方向枚举
enum Dir {Top,Right,Bottom,Left}
# 触摸方向
var touch_direction = Dir.Top
#布局数据
var chess_data = []
# 分数统计
var score: int = 0

func _ready() -> void:
	print("main ready")
	init_chess_data()
	render_chess()
	
func _input(event: InputEvent):
	if event is InputEventScreenTouch:
		if event.pressed:
			#print("触摸点按下: ", event.position)
			# 记录触摸开始位置
			touch_start_position = event.position
		else:
			#print("触摸点移除: ", event.position)
			calc_touch_direction(event)
	#elif event is InputEventScreenDrag:
		#print("触摸点移动: ", event.position)

func init_chess_data():
	var column = 4
	for i in range(column):
		chess_data.append([])
		for j in range(column):
			chess_data[i].append({
				"chess": null,
				"pos": Vector2(i,j),
				"val": 0
			})

# 生成一个棋子
func render_chess():
	var pos = find_random_empty_position()
	var val: int = 2
	if pos.x < 0 or pos.y < 0:
		return
	var piece_ins = PIECE_ITEM.instantiate()
	piece_ins.set_txt_value(pos, val)
	piece_con.add_child(piece_ins)
	# 设置棋子数据	
	chess_data[pos.x][pos.y] = {
		"chess": piece_ins,
		"pos": pos,
		"val": val
	}


func calc_touch_direction(event: InputEventScreenTouch):
	# 计算滑动距离
	var touch_end_position = event.position
	var direction = touch_end_position - touch_start_position
	if direction.length() > limit_value:  # 超过阈值
		# 根据向量的方向判断滑动方向
		if abs(direction.x) > abs(direction.y):
			if direction.x > 0:
				touch_direction = Dir.Right
			else:
				touch_direction = Dir.Left
		else:
			if direction.y > 0:
				touch_direction = Dir.Bottom
			else:
				touch_direction = Dir.Top

## 随机返回chess_data 为0的 x,y 坐标
##
## @return （x,y） 坐标
func find_random_empty_position() -> Vector2:
	var empty_positions = []  # 用于存储所有数值为 0 的位置

	# 遍历数组，找到所有数值为 0 的位置
	for i in range(chess_data.size()):
		for j in range(chess_data[i].size()):
			if chess_data[i][j].val == 0:
				empty_positions.append(Vector2(j, i))  # 将位置存储为 Vector2 类型

	# 如果没有找到任何数值为 0 的位置，返回一个默认值或抛出错误
	if empty_positions.size() == 0:
		push_error("No empty positions found.")
		return Vector2(-1, -1)  # 返回一个无效的坐标

	# 随机选择一个位置
	var random_index = randi() % empty_positions.size()
	return empty_positions[random_index]

# 处理棋子的移动
func handle_chess_move():
	var temp_data = []
	if touch_direction.Dir.Top or touch_direction.Dir.Bottom:
		for i in range(chess_data.size()):
			temp_data.push([])
			for j in range(chess_data[i].size()):
					temp_data[j].push(chess_data[i][j])
	else:
		temp_data = chess_data
	

func chess_top_move(chess_arr):
	for i in range(chess_arr.size()):
		for j in range(chess_arr[i].size()):
			if j > 0 :
				# 上一个				
				var pre = chess_arr[i][j-1]
				# 当前
				var current = chess_arr[i][j]
				pass
				

func chess_bottom_move():
	for i in range(chess_arr.size()):
		chess_arr[i].reverse()
	

func chess_left_move():
	pass

func chess_right_move():
	pass	
	
		
# 是否可以移动
func is_can_move():
	pass

# 合并棋子处理
func merge_chess():
	pass
