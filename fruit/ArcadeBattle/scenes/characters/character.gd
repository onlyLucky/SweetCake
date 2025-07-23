extends CharacterBody2D

@export var damage: int
@export var health: int
@export var speed: float

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var character_sprite: Sprite2D = $CharacterSprite
@onready var damage_emitter: Area2D = $DamageEmitter

enum State {IDLE, WALK,ATTACK}

var state = State.IDLE

func _ready() -> void:
	damage_emitter.area_entered.connect(on_emit_damage.bind())

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
	if can_move():
		# 速度检测
		if velocity.length() == 0:
			state = State.IDLE
		else:
			state = State.WALK
	else:
		velocity = Vector2.ZERO

func handle_input() -> void:
	# 单位向量 (Vector2.DOWN,Vector2.LEFT... 方向移动 对角线速度很快，同样一像素，对角线距离长)
	var direction := Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	#position += direction * delta * speed
	velocity = direction * speed
	
	# 检测是否触发攻击键
	if can_attack() and Input.is_action_just_pressed("attack"):
		state = State.ATTACK
	
func handle_animations()->void:
	if state == State.IDLE:
		animation_player.play("idle")
	elif state == State.WALK:
		animation_player.play("walk")
	elif state == State.ATTACK:
		animation_player.play("punch")

# 翻转角色
func flip_sprites() -> void:
	if velocity.x > 0:
		character_sprite.flip_h = false
		damage_emitter.scale.x = 1
	elif velocity.x < 0:
		character_sprite.flip_h = true
		damage_emitter.scale.x = -1

# 是否能移动
func can_move() -> bool:
	return state == State.IDLE or state == State.WALK

# 是否能攻击
func can_attack() -> bool:
	return state == State.IDLE or state == State.WALK

# 重置状态
func on_action_complete() -> void:
	state = State.IDLE

func on_emit_damage(damage_receiver: DamageReceiver) -> void:
	print(damage_receiver)
	var direction := Vector2.LEFT if damage_receiver.global_position.x<global_position.x else Vector2.RIGHT
	# 玩家传递给可破坏道具 damage_receiver 信号，附带伤害值
	damage_receiver.damage_receiver.emit(damage,direction)
