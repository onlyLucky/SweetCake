extends Node2D

const PIECE_ITEM = preload("res://scenes/PieceItem.tscn")

@onready var piece_con: Control = $MainCon/BG/ChessBox/ChessBorad/ChessBoardMargin/PieceCon
@onready var score_text: Label = $MainCon/BG/TextNum

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
# 棋盘的列数
const Chess_Column = 4

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
	for i in range(Chess_Column):
		chess_data.append([])
		for j in range(Chess_Column):
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
	piece_ins.set_cell_value(pos, val)
	piece_con.add_child(piece_ins)
	# 设置棋子数据	
	chess_data[pos.x][pos.y] = {
		"chess": piece_ins,
		"pos": pos,
		"val": val
	}
	print("render_chess",pos)


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
		handle_chess_move()

## 随机返回chess_data 为0的 x,y 坐标
##
## @return （x,y） 坐标
func find_random_empty_position() -> Vector2:
	var empty_positions = []  # 用于存储所有数值为 0 的位置

	# 遍历数组，找到所有数值为 0 的位置
	for i in range(chess_data.size()):
		for j in range(chess_data[i].size()):
			if chess_data[i][j].val == 0:
				empty_positions.append(Vector2(i,j))  # 将位置存储为 Vector2 类型

	# 如果没有找到任何数值为 0 的位置，返回一个默认值或抛出错误
	if empty_positions.size() == 0:
		push_error("No empty positions found.")
		# 重新开始
		restart()
		return Vector2(-1, -1)  # 返回一个无效的坐标

	# 随机选择一个位置
	var random_index = randi() % empty_positions.size()
	return empty_positions[random_index]

# 处理棋子的移动
func handle_chess_move():
	if touch_direction == Dir.Top:
		chess_top_move();
	if touch_direction == Dir.Bottom:
		chess_bottom_move();
	if touch_direction == Dir.Left:
		chess_left_move();
	if touch_direction == Dir.Right:
		chess_right_move();
	var tween = create_tween()
	tween.tween_interval(0.2)  # 延迟0.2秒
	tween.tween_callback(render_chess)
		

func chess_top_move():
	print_chess_num()
	for x in chess_data.size():
		var y = 0
		
		while y < chess_data[x].size():
			# 从 y + 1 位置开始，向下查找
			var next = y + 1
			while next < chess_data[x].size():
				# 如果 next 单元格是 0，找下一个不是 0 的单元格
				if chess_data[x][next].val == 0:
					next+=1
					continue
				# 如果 y 数字是 0，则将 next 移动到 y 位置，然后将 y 减 1 重新查找
				if chess_data[x][y].val == 0:
					chess_move({"from":chess_data[x][next],"to": chess_data[x][y]})
					y-=1
				# 如果 y 与 next 单元格数字相等，则将 next 移动并合并给 y
				elif chess_data[x][y].val == chess_data[x][next].val:
					chess_merge({"from":chess_data[x][next],"to": chess_data[x][y]})
				break
			y+=1	
	print_chess_num()
				

func chess_bottom_move():
	print_chess_num()
	for x in chess_data.size():
		var y = Chess_Column - 1
		
		while y >= 0:
			# 从 y - 1 位置开始，向上查找
			var pre = y - 1
			while pre >= 0:
				# 如果 pre 单元格是 0，找下一个不是 0 的单元格
				if chess_data[x][pre].val == 0:
					pre -= 1
					continue
				# 如果 y 数字是 0，则将 pre 移动到 y 位置，然后将 y 加 1 重新查找
				if chess_data[x][y].val == 0:
					chess_move({"from":chess_data[x][pre],"to": chess_data[x][y]})
					y+=1
				# 如果 y 与 pre 单元格数字相等，则将 pre 移动并合并给 y
				elif chess_data[x][y].val == chess_data[x][pre].val:
					chess_merge({"from": chess_data[x][pre],"to": chess_data[x][y]})
				break
			y-=1	
	print_chess_num()
	

# 左滑
func chess_left_move():
	print_chess_num()
	for y in Chess_Column:
		var x = 0
		while x < Chess_Column:
			var next = x+1
			while next < Chess_Column:
				if chess_data[next][y].val == 0:
					next += 1
					continue
				if chess_data[x][y].val == 0:
					chess_move({"from":chess_data[next][y],"to": chess_data[x][y]})
					x-=1
				elif chess_data[x][y].val == chess_data[next][y].val:
					chess_merge({"from":chess_data[next][y],"to": chess_data[x][y]})
				break
			x+=1
		
	print_chess_num()

func chess_right_move():
	print_chess_num()
	for y in Chess_Column:
		var x = Chess_Column - 1
		while x >= 0:
			var pre = x - 1
			while pre >= 0:
				if chess_data[pre][y].val == 0:
					pre -= 1
					continue
				if chess_data[x][y].val == 0:
					chess_move({"from":chess_data[pre][y],"to": chess_data[x][y]})
					x+=1
				elif chess_data[x][y].val == chess_data[pre][y].val:
					chess_merge({"from":chess_data[pre][y],"to": chess_data[x][y]})
				break
			x-=1
	print_chess_num()
	

func print_chess_num():
	var tempNum = []
	for x in chess_data.size():
		var new_arr = []
		for y in chess_data[x].size():
			new_arr.append(chess_data[y][x].val)
		tempNum.append(new_arr)
	#print(tempNum)
	
# 棋子移动
func chess_move(chessJson):
	var fromJson = chessJson.from
	var toJson = chessJson.to
	if not fromJson.chess:
		return
	fromJson.chess.move_pos(toJson.pos)
	#print("chess_move: ",chessJson.from.pos,chessJson.to.pos," -- ",chessJson.from.val,"moveTo",chessJson.to.val)
	# 数据更新
	chess_data[toJson.pos.x][toJson.pos.y].val = fromJson.val
	chess_data[toJson.pos.x][toJson.pos.y].chess = fromJson.chess
	chess_data[fromJson.pos.x][fromJson.pos.y].val = 0
	chess_data[fromJson.pos.x][fromJson.pos.y].chess = null
	
	

# 合并棋子处理
func chess_merge(chessJson):
	var fromJson = chessJson.from
	var toJson = chessJson.to
	fromJson.chess.move_pos(toJson.pos,true)
	var calcSum = fromJson.val + toJson.val
	toJson.chess.set_text(calcSum)
	#print("chess_merge: ",chessJson.from.pos,chessJson.to.pos," -- ",chessJson.from.val,"mergeTo",chessJson.to.val)
	# 数据更新
	chess_data[toJson.pos.x][toJson.pos.y].val = calcSum
	chess_data[fromJson.pos.x][fromJson.pos.y].chess = null;
	chess_data[fromJson.pos.x][fromJson.pos.y].val = 0
	# 计算分数
	updata_score(calcSum)

# 更新分数
func updata_score(addNum: int):
	score += addNum
	score_text.text = str(score)
	
func restart():
	# 清空piece_con节点的所有子节点
	for child in piece_con.get_children():
		child.queue_free()
	chess_data = []
	init_chess_data()
	score = 0
	score_text.text = str('')
	var tween = create_tween()
	tween.tween_interval(0.2)  # 延迟0.2秒
	tween.tween_callback(render_chess)
	

func _on_button_pressed() -> void:
	restart()
