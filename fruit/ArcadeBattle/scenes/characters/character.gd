extends CharacterBody2D

@export var damage: int
@export var health: int
@export var speed: float

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var character_sprite: Sprite2D = $CharacterSprite

enum State {IDLE, WALK}

var state = State.IDLE

# _delta 添加下划线 未使用的参数不报错
func _process(_delta: float) -> void:
	# delta 是上一帧到当前帧的时间间隔（秒） 不同性能的电脑delta是不一样的
	# position += Vector2.RIGHT * delta
	#if Input.is_action_pressed("ui_left"):
		#position += Vector2.LEFT * delta * speed
	#if Input.is_action_pressed("ui_right"):
		#position += Vector2.RIGHT * delta * speed
	#if Input.is_action_pressed("ui_up"):
		#position += Vector2.UP * delta * speed
	#if Input.is_action_pressed("ui_down"):
		#position += Vector2.DOWN * delta * speed
		
	# 状态机
	handle_input()
	handle_movement()
	handle_animations()
	flip_sprites()
	
	move_and_slide()

func handle_movement():
	# 速度检测
	if velocity.length() == 0:
		state = State.IDLE
	else:
		state = State.WALK

func handle_input() -> void:
	# 单位向量 (Vector2.DOWN,Vector2.LEFT... 方向移动 对角线速度很快，同样一像素，对角线距离长)
	var direction := Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	#position += direction * delta * speed
	velocity = direction * speed
	
func handle_animations()->void:
	if state == State.IDLE:
		animation_player.play("idle")
	elif state == State.WALK:
		animation_player.play("walk")

# 翻转角色
func flip_sprites() -> void:
	if velocity.x > 0:
		character_sprite.flip_h = false
	elif velocity.x < 0:
		character_sprite.flip_h = true
