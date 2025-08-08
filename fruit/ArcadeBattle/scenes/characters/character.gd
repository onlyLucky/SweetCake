## 角色类
class_name Character
extends CharacterBody2D

# 重力
const GRAVITY := 600.0

## 是否能复活
@export var can_respawn: bool
## 是否能生成飞刀
@export var can_respawn_knives: bool
## 伤害值
@export var damage: int
## 强力攻击伤害值
@export var damage_power: int
## 倒地时间
@export var duration_grounded: float
## 飞刀生成时间
@export var duration_between_knife_respawn: float
## 被强力攻击击飞的速度
@export var fligth_speed: float
## 是否带刀
@export var has_knife: bool
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
@onready var collateral_damage_emitter: Area2D = $CollateralDamageEmitter
@onready var collectible_sensor: Area2D = $CollectibleSensor
@onready var knife_sprite: Sprite2D = $KnifeSprite
@onready var projectile_aim: RayCast2D = $ProjectileAim


# fall 下落
enum State {IDLE, WALK,ATTACK,TAKEOFF,JUMP,LAND,JUMPKICK,HURT,FALL, GROUNDED, DEATH, FLY,PREP_ATTACK,THROW,PICKUP }

var anim_attacks := []
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
	State.FLY: "fly",
	State.PREP_ATTACK : "idle",
	State.THROW : "throw",
	State.PICKUP : "pickup",
}
# 攻击连招 下标
var attack_combo_index := 0
var current_health := 0
# 跳跃高度
var height := 0.0
# 角色朝向
var heading:=Vector2.RIGHT
# 跳跃高度速度
var height_speed := 0.0
# 最后一击是否成功
var is_last_hit_successful := false
var state = State.IDLE
# 倒地站起
var time_since_grounded:=Time.get_ticks_msec()
# 生成飞刀
var time_since_knife_dismiss:=Time.get_ticks_msec()

func _ready() -> void:
	damage_emitter.area_entered.connect(on_emit_damage.bind())
	damage_receiver.damage_receiver.connect(on_receive_damage.bind())
	collateral_damage_emitter.area_entered.connect(on_emit_collateral_damage.bind())
	collateral_damage_emitter.body_entered.connect(on_wall_hit.bind())
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
	handle_prep_attack()
	# 处理地面状态
	handle_grounded()
	handle_knife_respawn()
	# 处理死亡处理
	handle_death(_delta)
	# 设置朝向
	set_heading()
	flip_sprites()
	knife_sprite.visible = has_knife
	character_sprite.position = Vector2.UP * height
	knife_sprite.position = Vector2.UP * height
	# 设置倒地，死亡状态，碰撞体不触发
	collision_shape.disabled = is_collsion_disabled()
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

# 等待攻击
func handle_prep_attack() -> void:
	pass
	
func handle_grounded():
	if state == State.GROUNDED and (Time.get_ticks_msec() - time_since_grounded > duration_grounded):
		if current_health == 0:
			state = State.DEATH
		else:
			state = State.LAND

func handle_knife_respawn() -> void:
	if can_respawn_knives and not has_knife and (Time.get_ticks_msec() - time_since_knife_dismiss > duration_between_knife_respawn):
		has_knife = true

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

func set_heading():
	pass
			
# 翻转角色
func flip_sprites() -> void:
	if heading == Vector2.RIGHT:
		character_sprite.flip_h = false
		knife_sprite.flip_h = false
		damage_emitter.scale.x = 1
		projectile_aim.scale.x = 1
	else:
		character_sprite.flip_h = true
		knife_sprite.flip_h = true
		damage_emitter.scale.x = -1
		projectile_aim.scale.x = -1

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

func can_pickup_collectible() -> bool:
	var collectible_areas := collectible_sensor.get_overlapping_areas()
	if collectible_areas.size() == 0:
		return false
	var collectible: Collectible = collectible_areas[0]
	if collectible.type == Collectible.Type.KNIFE and not has_knife:
		return true
	return false

func pickup_collectible() -> void:
	if can_pickup_collectible():
		var collectible_areas := collectible_sensor.get_overlapping_areas()
		var collectible: Collectible = collectible_areas[0]
		if collectible.type == Collectible.Type.KNIFE and not has_knife:
			has_knife = true
		collectible.queue_free()

func is_collsion_disabled() -> bool:
	return [State.GROUNDED,State.DEATH,State.FLY].has(state)
	

# 重置状态
func on_action_complete() -> void:
	state = State.IDLE

func on_throw_complete() -> void:
	state = State.IDLE
	has_knife = false

# 起跳切换
func on_takeoff_complete() -> void:
	state = State.JUMP
	height_speed = jump_intensity

func on_pickup_complete() -> void:
	state = State.IDLE
	pickup_collectible()

# 落地回调	
func on_land_complete() -> void:
	state = State.IDLE

# 角色伤害收信号
func on_receive_damage(amount: int, direction: Vector2,hit_type: DamageReceiver.HitType) -> void:
	if can_get_hurt():
		if has_knife:
			has_knife = false
			time_since_knife_dismiss = Time.get_ticks_msec()
		current_health = clamp(current_health - amount,0, max_health)
		# 血量为空 被击倒 立马倒地
		if current_health == 0 or hit_type == DamageReceiver.HitType.KNOCKDOWN:
			state = State.FALL
			height_speed = knockdown_intensity
			velocity = direction * knockback_intensity
		elif hit_type == DamageReceiver.HitType.POWER:
			#强力击飞
			state = State.FLY
			velocity = direction * fligth_speed
		else:
			#击退
			state = State.HURT
			velocity = direction * knockback_intensity

func on_emit_damage(receiver: DamageReceiver) -> void:
	var hit_type = DamageReceiver.HitType.NORMAL
	var direction := Vector2.LEFT if receiver.global_position.x<global_position.x else Vector2.RIGHT
	var current_damage = damage
	if state == State.JUMPKICK:
		hit_type = DamageReceiver.HitType.KNOCKDOWN
		
	# 判断强力攻击
	if attack_combo_index == anim_attacks.size() - 1:
		hit_type = DamageReceiver.HitType.POWER
		current_damage = damage_power
	# 玩家传递给可破坏道具 damage_receiver 信号，附带伤害值
	receiver.damage_receiver.emit(current_damage,direction,hit_type)
	is_last_hit_successful = true

# 隐形墙伤害接收器
func on_emit_collateral_damage(receiver: DamageReceiver) -> void:
	if receiver != damage_receiver:
		var direction := Vector2.LEFT if receiver.global_position.x<global_position.x else Vector2.RIGHT
		receiver.damage_receiver.emit(0,direction,DamageReceiver.HitType.KNOCKDOWN)

# 碰到左右两边隐性墙体 事件
func on_wall_hit(_wall: AnimatableBody2D):
	state = State.FALL
	height_speed = knockdown_intensity
	# 碰到墙体反弹回来
	velocity = -velocity / 2.0
	
