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
	for black in snake_body:
		snake_apple.set_cell(black,MAP_TYPE.SNACKE,Vector2i(7,0))

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
	if Input.is_action_just_pressed("ui_up") and snake_direction != Vector2i.DOWN:
		snake_direction = Vector2i.UP
	if Input.is_action_just_pressed("ui_down") and snake_direction != Vector2i.UP:
		snake_direction = Vector2i.DOWN
	if Input.is_action_just_pressed("ui_left") and snake_direction != Vector2i.RIGHT:
		snake_direction = Vector2i.LEFT
	if Input.is_action_just_pressed("ui_right") and snake_direction != Vector2i.LEFT:
		snake_direction = Vector2i.RIGHT

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
