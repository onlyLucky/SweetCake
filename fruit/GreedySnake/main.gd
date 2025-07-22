extends Node2D

@onready var snake_apple: TileMapLayer = $SnakeApple

enum MAP_TYPE {
	SNACKE = 0,
	APPLE = 1
}

var apple_pos: Vector2i = Vector2i.ZERO
var snake_body: Array = [Vector2i(5,10),Vector2i(4,10),Vector2i(3,10)]
var snake_direction: Vector2i = Vector2i.RIGHT
# 是否吃了苹果
var eaten_apple: bool=false

var _last_direction_change_time := 0.0
var _direction_change_cooldown := 0.15  # 150毫秒冷却时间（可根据手感调整）

func _ready() -> void:
	apple_pos = place_apple()
	draw_apple()
	draw_snack()

# 随机苹果
func place_apple() -> Vector2i:
	randomize()
	var x:int = randi() % 20
	var y:int = randi() % 20
	return Vector2i(x,y)

# 画苹果
func draw_apple():
	print("draw_apple",apple_pos)
	snake_apple.set_cell(apple_pos,MAP_TYPE.APPLE,Vector2i.ZERO)

# 画蛇
func draw_snack():
	for block_index in snake_body.size():
		var block: Vector2i = snake_body[block_index]
		var tile_pos: Vector2i = Vector2i(7,0)
		# 头
		if block_index == 0:
			match snake_direction:
				Vector2i.LEFT:
					tile_pos = Vector2i(3,1)
				Vector2i.RIGHT:
					tile_pos = Vector2i(2,0)
				Vector2i.UP:
					tile_pos = Vector2i(2,1)
				Vector2i.DOWN:
					tile_pos = Vector2i(3,0)
		# 尾
		elif block_index == snake_body.size() - 1:
			var tail_direction = snake_body[-2] - snake_body[-1]
			match tail_direction:
				Vector2i.LEFT:
					tile_pos = Vector2i(1,0)
				Vector2i.RIGHT:
					tile_pos = Vector2i(0,0)
				Vector2i.UP:
					tile_pos = Vector2i(1,1)
				Vector2i.DOWN:
					tile_pos = Vector2i(0,1)
		else:
			var pre_diff: Vector2i = snake_body[block_index - 1] - block
			var next_diff: Vector2i = snake_body[block_index + 1] - block
			# 前块与后块差值 垂直移动
			if pre_diff.x == next_diff.x:
				tile_pos = Vector2i(4,1)
			# 前块与后块差值 水平移动
			if pre_diff.y == next_diff.y:
				tile_pos = Vector2i(4,0)
			
			# 转角
			# (5,11) (5,10) (6,10) 计算前一个与后一个差值计算比较，转角判断
			# 左下转
			if (pre_diff.x == 1 and next_diff.y == 1) or (next_diff.x == 1 and pre_diff.y == 1):
				tile_pos = Vector2i(5,0)
			# 下左转	
			if (pre_diff.x == -1 and next_diff.y == -1) or (next_diff.x == -1 and pre_diff.y == -1):
				tile_pos = Vector2i(6,1)
			# 右下转
			if (pre_diff.x == -1 and next_diff.y == 1) or (next_diff.x == -1 and pre_diff.y == 1):
				tile_pos = Vector2i(6,0)
			# 下右转
			if (pre_diff.x == 1 and next_diff.y == -1) or (next_diff.x == 1 and pre_diff.y == -1):
				tile_pos = Vector2i(5,1)
			
		snake_apple.set_cell(block,MAP_TYPE.SNACKE,tile_pos)

# 定时器绑定
func _on_snake_tick_timeout() -> void:
	move_snake()
	draw_apple()
	draw_snack()
	check_apple_eaten()
	
# 蛇移动
func move_snake():
	delete_tiles()
	var body_copy: Array
	if eaten_apple==true:
		body_copy = snake_body.slice(0, snake_body.size())
		eaten_apple = false
	else:
		body_copy = snake_body.slice(0, snake_body.size() - 1)
	var new_head: Vector2i = body_copy[0] + snake_direction
	body_copy.insert(0, new_head)
	snake_body = body_copy

# 删除所有的蛇tile
func delete_tiles():
	var cells = snake_apple.get_used_cells_by_id(MAP_TYPE.SNACKE)
	for cell in cells:
		snake_apple.set_cell(cell,-1)

# 检测方向输入
func _input(event: InputEvent) -> void:
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - _last_direction_change_time < _direction_change_cooldown:
		return
	
	var new_direction := snake_direction
	if Input.is_action_just_pressed("ui_up") and snake_direction != Vector2i.DOWN:
		new_direction = Vector2i.UP
	if Input.is_action_just_pressed("ui_down") and snake_direction != Vector2i.UP:
		new_direction = Vector2i.DOWN
	if Input.is_action_just_pressed("ui_left") and snake_direction != Vector2i.RIGHT:
		new_direction = Vector2i.LEFT
	if Input.is_action_just_pressed("ui_right") and snake_direction != Vector2i.LEFT:
		new_direction = Vector2i.RIGHT
	
	if new_direction != snake_direction:
		snake_direction = new_direction
		_last_direction_change_time = current_time

# 检测苹果是否被吃掉了
func check_apple_eaten():
	if apple_pos == snake_body[0]:
		eaten_apple = true
		apple_pos = place_apple()

# 检测游戏结束
func check_game_over():
	var head:Vector2i = snake_body[0]
	if head.x > 20 or head.x < 0 or head.y < 0 or head.y > 20:
		reset()

# 重置游戏
func reset():
	snake_body = [Vector2i(5,10),Vector2i(4,10),Vector2i(3,10)]
	snake_direction = Vector2i.RIGHT

func _process(delta: float) -> void:
	check_game_over()
