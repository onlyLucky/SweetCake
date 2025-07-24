class_name BasicEnemy
extends Character

@export var player: Player

func handle_input()->void:
	if player != null and can_move():
		# 向玩家移动
		var direction := (player.position - position).normalized()
		velocity = direction * speed
