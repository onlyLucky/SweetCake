class_name Character
extends CharacterBody2D

# 重力
const GRAVITY := 600.0

## 是否能复活
@export var can_respawn: bool
@export var damage: int
## 倒地时间
@export var duration_grounded: float
## 跳跃强度
@export var jump_intensity:float
## 击退强度
@export var knockback_intensity: float
## 击倒强度
@export var knockdown_intensity: float
@export var max_health: int
@export var speed: float

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var character_sprite: Sprite2D = $CharacterSprite
@onready var damage_emitter: Area2D = $DamageEmitter
@onready var damage_receiver: DamageReceiver = $DamageReceiver
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

# fall 下落
enum State {IDLE, WALK,ATTACK,TAKEOFF,JUMP,LAND,JUMPKICK,HURT,FALL, GROUNDED, DEATH }

var anim_attacks := ["punch","punch_alt","kick","roundkick"]
var anim_map := {
	State.IDLE: "idle",
	State.WALK: "walk",
	#State.ATTACK: "punch",
	State.TAKEOFF: "takeoff",
	State.JUMP: "jump",
	State.LAND: "land",
	State.JUMPKICK: "jumpkick",
	State.HURT: "hurt",
	State.FALL: "fall",
	State.GROUNDED: "grounded",
	State.DEATH: "grounded",
}
# 攻击连招 下标
var attack_combo_index := 0
var current_health := 0
# 跳跃高度
var height := 0.0
# 跳跃高度速度
var height_speed := 0.0
# 最后一击是否成功
var is_last_hit_successful := false
var state = State.IDLE
var time_since_grounded:=Time.get_ticks_msec()

func _ready() -> void:
	damage_emitter.area_entered.connect(on_emit_damage.bind())
	damage_receiver.damage_receiver.connect(on_receive_damage.bind())
	current_health = max_health

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
	# 处理空中时间
	handle_air_time(_delta)
	# 处理地面状态
	handle_grounded()
	# 处理死亡处理
	handle_death(_delta)
	flip_sprites()
	character_sprite.position = Vector2.UP * height
	collision_shape.disabled = state == State.GROUNDED
	move_and_slide()

# 处理移动
func handle_movement():
	if can_move():
		# 速度检测
		if velocity.length() == 0:
			state = State.IDLE
		else:
			state = State.WALK

func handle_input() -> void:
	pass
	
func handle_grounded():
	if state == State.GROUNDED and (Time.get_ticks_msec() - time_since_grounded > duration_grounded):
		if current_health == 0:
			state = State.DEATH
		else:
			state = State.LAND

func handle_death(delta: float):
	if state == State.DEATH and not can_respawn:
		# 两秒透明度归0
		modulate.a -= delta / 2.0
		if modulate.a <= 0:
			queue_free()
	
func handle_animations()->void:
	if state == State.ATTACK:
		animation_player.play(anim_attacks[attack_combo_index])
	elif animation_player.has_animation(anim_map[state]):
		animation_player.play(anim_map[state])

func handle_air_time(delta: float)-> void:
	if [State.JUMP,State.JUMPKICK,State.FALL].has(state):
		height += height_speed * delta
		if height < 0:
			height = 0
			if state == State.FALL:
				state = State.GROUNDED
				time_since_grounded = Time.get_ticks_msec()
			else:
				state = State.LAND
			velocity = Vector2.ZERO
		else: 
			height_speed -= GRAVITY * delta
			
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

# 是否能跳跃
func can_jump() -> bool:
	return state == State.IDLE or state == State.WALK
	
# 是否能跳踢
func can_jumpkick() -> bool:
	return state == State.JUMP

func can_get_hurt() -> bool:
	return [State.IDLE, State.WALK, State.TAKEOFF, State.JUMP, State.LAND].has(state)

# 重置状态
func on_action_complete() -> void:
	state = State.IDLE
# 起跳切换
func on_takeoff_complete() -> void:
	state = State.JUMP
	height_speed = jump_intensity
# 落地回调	
func on_land_complete() -> void:
	state = State.IDLE

# 角色伤害收信号
func on_receive_damage(amount: int, direction: Vector2,hit_type: DamageReceiver.HitType) -> void:
	if can_get_hurt():
		current_health = clamp(current_health - amount,0, max_health)
		# 血量为空 被击倒 立马倒地
		if current_health == 0 or hit_type == DamageReceiver.HitType.KNOCKDOWN:
			state = State.FALL
			height_speed = knockdown_intensity
		else:
			#击退
			state = State.HURT
		velocity = direction * knockback_intensity

func on_emit_damage(receiver: DamageReceiver) -> void:
	var hit_type = DamageReceiver.HitType.NORMAL
	var direction := Vector2.LEFT if receiver.global_position.x<global_position.x else Vector2.RIGHT
	if state == State.JUMPKICK:
		hit_type = DamageReceiver.HitType.KNOCKDOWN
	# 玩家传递给可破坏道具 damage_receiver 信号，附带伤害值
	receiver.damage_receiver.emit(damage,direction,hit_type)
	is_last_hit_successful = true
