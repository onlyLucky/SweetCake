class_name BasicEnemy
extends Character

@export var player: Player

var player_slot: EnemySlot = null

func handle_input()->void:
	if player != null and can_move():
		
		# 判断玩家插槽是否还有空位
		if player_slot == null:
			player_slot = player.reserve_slot(self)
		
		if player_slot != null:
			# 向玩家移动
			# 同一个层级的节点树之下可以使用 position 不在同一层级 可以使用global_position
			var direction := (player_slot.global_position - global_position).normalized()
			velocity = direction * speed
				
