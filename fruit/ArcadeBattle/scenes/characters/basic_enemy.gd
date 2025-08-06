class_name BasicEnemy
extends Character

const EDGE_SCREEN_BUFFER := 10

## 近战两次攻击之间间隔时间
@export var duration_between_melee_attack: int
## 远程两次攻击之间间隔时间
@export var duration_between_range_attack: int
## 近战攻击等待时间
@export var duration_prep_melee_attack: int
## 远程攻击等待时间
@export var duration_prep_range_attack: int
@export var player: Player

var player_slot: EnemySlot = null
var time_since_last_melee_attack:=Time.get_ticks_msec()
var time_since_prep_melee_attack:=Time.get_ticks_msec()
var time_since_last_range_attack:=Time.get_ticks_msec()
var time_since_prep_range_attack:=Time.get_ticks_msec()


func _ready() -> void:
	super._ready()
	anim_attacks = ["punch","punch_alt"]

func handle_input()->void:
	if player != null and can_move():
		if can_respawn_knives:
			goto_range_position()
		else:
			goto_melee_position()

# 远程攻击移动
func goto_range_position()->void:
	pass

# 近程攻击移动
func goto_melee_position()->void:
	# 判断玩家插槽是否还有空位
	if player_slot == null:
		player_slot = player.reserve_slot(self)
	
	if player_slot != null:
		# 向玩家移动
		# 同一个层级的节点树之下可以使用 position 不在同一层级 可以使用global_position
		var direction := (player_slot.global_position - global_position).normalized()
		# 向量相减 取length 是向量的长度
		if is_player_within_range():
			velocity = Vector2.ZERO
			if can_attack():
				state = State.PREP_ATTACK
				time_since_prep_melee_attack = Time.get_ticks_msec()
		else:
			velocity = direction * speed

## 处理准备攻击工作
func handle_prep_attack()->void:
	if state == State.PREP_ATTACK and (Time.get_ticks_msec() - time_since_prep_melee_attack < duration_prep_melee_attack):
		state = State.ATTACK
		time_since_last_melee_attack = Time.get_ticks_msec()
		#随机打乱数组中所有元素的顺序
		anim_attacks.shuffle()

## 判断玩家插槽距离 单位有 1
func is_player_within_range() -> bool:
	return (player_slot.global_position - global_position).length() < 1
	
func can_attack() -> bool:
	if Time.get_ticks_msec() - time_since_last_melee_attack < duration_between_melee_attack:
		return false
	return super.can_attack()

func can_throw() -> bool:
	if Time.get_ticks_msec() - time_since_last_range_attack < duration_between_range_attack:
		return false
	return super.can_attack()

func set_heading():
	if player == null:
		return
	heading = Vector2.LEFT if position.x>player.position.x else Vector2.RIGHT

func on_receive_damage(amount: int, direction: Vector2, hit_type: DamageReceiver.HitType) -> void:
	super.on_receive_damage(amount,direction,hit_type)
	if current_health == 0:
		player.free_slot(self)
	
	
