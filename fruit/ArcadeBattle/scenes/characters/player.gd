class_name Player
extends Character

func handle_input() ->void:
	# 单位向量 (Vector2.DOWN,Vector2.LEFT... 方向移动 对角线速度很快，同样一像素，对角线距离长)
	var direction := Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	#position += direction * delta * speed
	velocity = direction * speed
	
	# 检测是否触发攻击键
	if can_attack() and Input.is_action_just_pressed("attack"):
		state = State.ATTACK
	# 检测起跳
	if can_jump() and Input.is_action_just_pressed("jump"):
		state = State.TAKEOFF
	# 检测起跳踢
	if can_jumpkick() and Input.is_action_just_pressed("attack"):
		state = State.JUMPKICK
