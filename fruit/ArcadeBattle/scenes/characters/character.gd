extends CharacterBody2D

@export var health: int
@export var damage: int
@export var speed: float

func _process(delta: float) -> void:
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
	
	# 单位向量 (Vector2.DOWN,Vector2.LEFT... 方向移动 对角线速度很快，同样一像素，对角线距离长)
	var direction := Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	#position += direction * delta * speed
	velocity = direction * speed
	move_and_slide()
