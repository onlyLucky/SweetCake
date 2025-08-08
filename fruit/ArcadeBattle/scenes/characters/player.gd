class_name Player
extends Character

# 敌人对应槽位
@onready var enemy_slots: Array = $EnemySlots.get_children()

func _ready() -> void:
	super._ready()
	anim_attacks = ["punch","punch_alt","kick","roundkick"]

func handle_input() ->void:
	# 单位向量 (Vector2.DOWN,Vector2.LEFT... 方向移动 对角线速度很快，同样一像素，对角线距离长)
	var direction := Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	#position += direction * delta * speed
	velocity = direction * speed
	
	# 检测是否触发攻击键
	if can_attack() and Input.is_action_just_pressed("attack"):
		if has_knife:
			state = State.THROW
		else:
			if can_pickup_collectible():
				state = State.PICKUP
			else:
				state = State.ATTACK
				if is_last_hit_successful:
					attack_combo_index = (attack_combo_index+1) % anim_attacks.size()
					is_last_hit_successful = false
				else:
					attack_combo_index = 0
	# 检测起跳
	if can_jump() and Input.is_action_just_pressed("jump"):
		state = State.TAKEOFF
	# 检测起跳踢
	if can_jumpkick() and Input.is_action_just_pressed("attack"):
		state = State.JUMPKICK

func set_heading():
	if velocity.x>0:
		heading = Vector2.RIGHT
	elif velocity.x < 0:
		heading = Vector2.LEFT

# 接受敌人槽位
func reserve_slot(enemy: BasicEnemy) -> EnemySlot:
	var available_slots := enemy_slots.filter(
		func(slot): return slot.is_free()
	)
	if available_slots.size() == 0:
		return null
	# 排序最小距离在最前面
	available_slots.sort_custom(
		func(a: EnemySlot, b: EnemySlot):
			var dis_a := (enemy.global_position - a.global_position).length()
			var dis_b := (enemy.global_position - b.global_position).length()
			return dis_a < dis_b
	)
	available_slots[0].occupy(enemy)
	return available_slots[0]


# 释放指定敌人所指定的槽位
func free_slot(enemy: BasicEnemy) -> void:
	var target_slots := enemy_slots.filter(
		func(slot: EnemySlot):
			return slot.occupant == enemy
	)
	if target_slots.size() == 1:
		target_slots[0].free_up()
	
	
