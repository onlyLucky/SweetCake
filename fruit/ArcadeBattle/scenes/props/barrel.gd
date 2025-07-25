extends StaticBody2D

@onready var damage_receiver: DamageReceiver = $DamageReceiver
@onready var sprite_2d: Sprite2D = $Sprite2D

# 控制运动速度参数
@export var knockback_intesity: float

enum State {IDLE, DESTROYED}

# 重力
const GRAVITY := 600.0

var height := 0.0
var height_speed := 0.0
var state := State.IDLE
var velocity := Vector2.ZERO

func _ready() -> void:
	damage_receiver.damage_receiver.connect(on_receive_damage.bind())

func _process(delta: float) -> void:
	position += velocity * delta
	sprite_2d.position = Vector2.UP * height
	handle_air_time(delta)

func on_receive_damage(_damage:int, direction: Vector2)->void:
	if state == State.IDLE:
		# 桶被抛起
		sprite_2d.frame = 1
		height_speed = knockback_intesity*2
		state = State.DESTROYED
		velocity = direction * knockback_intesity

func handle_air_time(delta: float) -> void:
	if state == State.DESTROYED:
		modulate.a -= delta
		height += height_speed * delta
		if height < 0:
			height = 0
			queue_free()
		else:
			height_speed -= GRAVITY*delta
